const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * Cloud Function que se dispara cuando se crea un nuevo mensaje
 * Envía notificación push al destinatario
 */
exports.sendMessageNotification = functions.firestore
    .document('matches/{matchId}/messages/{messageId}')
    .onCreate(async (snap, context) => {
        try {
            const messageData = snap.data();
            const matchId = context.params.matchId;
            const senderId = messageData.senderId;
            const messageText = messageData.text;

            console.log(`📩 Nuevo mensaje en match ${matchId} de ${senderId}`);

            // Obtener información del match para saber quién es el destinatario
            const matchDoc = await admin.firestore()
                .collection('matches')
                .doc(matchId)
                .get();

            if (!matchDoc.exists) {
                console.error('❌ Match no encontrado');
                return null;
            }

            const matchData = matchDoc.data();
            const users = matchData.users || [];

            // Encontrar el ID del destinatario (el que no es el sender)
            const recipientId = users.find(userId => userId !== senderId);

            if (!recipientId) {
                console.error('❌ No se pudo identificar al destinatario');
                return null;
            }

            console.log(`👤 Destinatario: ${recipientId}`);

            // Obtener información del remitente para la notificación
            const senderDoc = await admin.firestore()
                .collection('users')
                .doc(senderId)
                .get();

            if (!senderDoc.exists) {
                console.error('❌ Usuario remitente no encontrado');
                return null;
            }

            const senderData = senderDoc.data();
            const senderName = senderData.name || 'Alguien';
            const senderPhoto = senderData.photos && senderData.photos.length > 0
                ? senderData.photos[0]
                : null;

            // Obtener tokens FCM del destinatario
            const tokensDoc = await admin.firestore()
                .collection('users')
                .doc(recipientId)
                .collection('private')
                .doc('fcmTokens')
                .get();

            if (!tokensDoc.exists) {
                console.log('⚠️ Destinatario no tiene tokens FCM registrados');
                return null;
            }

            const tokensData = tokensDoc.data();
            const tokens = tokensData.tokens || [];

            if (tokens.length === 0) {
                console.log('⚠️ Destinatario no tiene tokens FCM activos');
                return null;
            }

            console.log(`📱 Enviando notificación a ${tokens.length} dispositivo(s)`);

            // Preparar el mensaje de notificación
            const payload = {
                notification: {
                    title: senderName,
                    body: messageText.length > 100
                        ? messageText.substring(0, 97) + '...'
                        : messageText,
                    ...(senderPhoto && { imageUrl: senderPhoto }),
                },
                data: {
                    conversationId: matchId,
                    senderId: senderId,
                    type: 'chat_message',
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                },
                android: {
                    priority: 'high',
                    notification: {
                        channelId: 'chat_messages',
                        sound: 'default',
                        priority: 'high',
                    },
                },
                apns: {
                    payload: {
                        aps: {
                            sound: 'default',
                            badge: 1,
                        },
                    },
                },
            };

            // Enviar notificación a todos los tokens
            const response = await admin.messaging().sendEachForMulticast({
                tokens: tokens,
                ...payload,
            });

            console.log(`✅ Notificación enviada: ${response.successCount} éxitos, ${response.failureCount} fallos`);

            // Limpiar tokens inválidos
            if (response.failureCount > 0) {
                const tokensToRemove = [];
                response.responses.forEach((resp, idx) => {
                    if (!resp.success) {
                        console.error(`❌ Error enviando a token ${idx}:`, resp.error);
                        // Si el token es inválido, marcarlo para eliminación
                        if (resp.error.code === 'messaging/invalid-registration-token' ||
                            resp.error.code === 'messaging/registration-token-not-registered') {
                            tokensToRemove.push(tokens[idx]);
                        }
                    }
                });

                // Eliminar tokens inválidos de Firestore
                if (tokensToRemove.length > 0) {
                    console.log(`🧹 Eliminando ${tokensToRemove.length} token(s) inválido(s)`);
                    await admin.firestore()
                        .collection('users')
                        .doc(recipientId)
                        .collection('private')
                        .doc('fcmTokens')
                        .update({
                            tokens: admin.firestore.FieldValue.arrayRemove(...tokensToRemove),
                        });
                }
            }

            return null;
        } catch (error) {
            console.error('❌ Error en sendMessageNotification:', error);
            return null;
        }
    });

/**
 * Cloud Function que se dispara cuando se crea un nuevo match
 * Envía notificación push a ambos usuarios
 */
exports.onMatchCreated = functions.firestore
    .document('matches/{matchId}')
    .onCreate(async (snap, context) => {
        try {
            const matchData = snap.data();
            const matchId = context.params.matchId;
            const users = matchData.users || [];

            if (users.length !== 2) {
                console.error('❌ Match debe tener exactamente 2 usuarios');
                return null;
            }

            const [userId1, userId2] = users;
            console.log(`💕 Nuevo match creado: ${userId1} ↔️ ${userId2}`);

            // Obtener información de ambos usuarios
            const [user1Doc, user2Doc] = await Promise.all([
                admin.firestore().collection('users').doc(userId1).get(),
                admin.firestore().collection('users').doc(userId2).get(),
            ]);

            if (!user1Doc.exists || !user2Doc.exists) {
                console.error('❌ No se pudieron obtener los datos de los usuarios');
                return null;
            }

            const user1Data = user1Doc.data();
            const user2Data = user2Doc.data();

            // Obtener tokens de ambos usuarios
            const [tokens1Doc, tokens2Doc] = await Promise.all([
                admin.firestore()
                    .collection('users')
                    .doc(userId1)
                    .collection('private')
                    .doc('fcmTokens')
                    .get(),
                admin.firestore()
                    .collection('users')
                    .doc(userId2)
                    .collection('private')
                    .doc('fcmTokens')
                    .get(),
            ]);

            // Función helper para enviar notificación a un usuario
            const sendMatchNotification = async (recipientId, recipientTokensDoc, matchedUserData) => {
                if (!recipientTokensDoc.exists) {
                    console.log(`⚠️ Usuario ${recipientId} no tiene tokens FCM`);
                    return { successCount: 0, failureCount: 0 };
                }

                const tokensData = recipientTokensDoc.data();
                const tokens = tokensData.tokens || [];

                if (tokens.length === 0) {
                    console.log(`⚠️ Usuario ${recipientId} no tiene tokens activos`);
                    return { successCount: 0, failureCount: 0 };
                }

                const matchedUserName = matchedUserData.name || 'Alguien';
                const matchedUserPhoto = matchedUserData.photos && matchedUserData.photos.length > 0
                    ? matchedUserData.photos[0]
                    : null;

                const payload = {
                    notification: {
                        title: '¡Nuevo Match! 💕',
                        body: `¡Hiciste match con ${matchedUserName}!`,
                        ...(matchedUserPhoto && { imageUrl: matchedUserPhoto }),
                    },
                    data: {
                        conversationId: matchId,
                        matchedUserId: matchedUserData.uid || matchedUserData.id,
                        type: 'new_match',
                        click_action: 'FLUTTER_NOTIFICATION_CLICK',
                    },
                    android: {
                        priority: 'high',
                        notification: {
                            channelId: 'chat_messages',
                            sound: 'default',
                            priority: 'high',
                            tag: 'match',
                        },
                    },
                    apns: {
                        payload: {
                            aps: {
                                sound: 'default',
                                badge: 1,
                            },
                        },
                    },
                };

                console.log(`📱 Enviando notificación de match a ${recipientId}`);
                const response = await admin.messaging().sendEachForMulticast({
                    tokens: tokens,
                    ...payload,
                });

                console.log(`✅ Match notification: ${response.successCount} éxitos, ${response.failureCount} fallos`);

                // Limpiar tokens inválidos
                if (response.failureCount > 0) {
                    const tokensToRemove = [];
                    response.responses.forEach((resp, idx) => {
                        if (!resp.success &&
                            (resp.error.code === 'messaging/invalid-registration-token' ||
                                resp.error.code === 'messaging/registration-token-not-registered')) {
                            tokensToRemove.push(tokens[idx]);
                        }
                    });

                    if (tokensToRemove.length > 0) {
                        await admin.firestore()
                            .collection('users')
                            .doc(recipientId)
                            .collection('private')
                            .doc('fcmTokens')
                            .update({
                                tokens: admin.firestore.FieldValue.arrayRemove(...tokensToRemove),
                            });
                    }
                }

                return response;
            };

            // Enviar notificaciones a ambos usuarios
            await Promise.all([
                sendMatchNotification(userId1, tokens1Doc, user2Data),
                sendMatchNotification(userId2, tokens2Doc, user1Data),
            ]);

            console.log('✅ Notificaciones de match enviadas a ambos usuarios');
            return null;
        } catch (error) {
            console.error('❌ Error en onMatchCreated:', error);
            return null;
        }
    });

/**
 * Cloud Function para limpiar tokens FCM expirados (opcional)
 * Se puede ejecutar periódicamente con Cloud Scheduler
 */
exports.cleanupExpiredTokens = functions.pubsub
    .schedule('every 24 hours')
    .onRun(async (context) => {
        console.log('🧹 Iniciando limpieza de tokens expirados');

        // Esta función se puede implementar más adelante si es necesario
        // Por ahora, la limpieza se hace en sendMessageNotification

        return null;
    });
