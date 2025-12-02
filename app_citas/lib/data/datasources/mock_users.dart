import '../models/user_model.dart';

/// Datos de prueba para el feed de usuarios
class MockUsers {
  static List<UserModel> getMockUsers() {
    return [
      UserModel(
        id: '1',
        uid: 'user1',
        name: 'Sofia',
        age: 24,
        bio:
            'Amante del café, los libros y las aventuras. Buscando alguien con quien compartir risas y buenos momentos ☕📚',
        photos: [
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800',
        ],
        location: UserLocation(
          country: 'Argentina',
          state: 'Buenos Aires',
          city: 'Buenos Aires',
        ),
        distance: 2.5,
        interests: ['Café', 'Lectura', 'Viajes', 'Fotografía'],
        gender: 'Mujer',
        sexualOrientation: 'Heterosexual',
        job: UserJob(
          title: 'Diseñadora',
          company: 'Freelance',
          education: 'Universitario',
        ),
        lifestyle: UserLifestyle(
          drink: 'Socialmente',
          smoke: 'No',
          workout: 'A veces',
          zodiac: 'Leo',
          height: '165',
        ),
        searchIntent: 'Relación seria',
      ),
      UserModel(
        id: '2',
        uid: 'user2',
        name: 'Valentina',
        age: 26,
        bio: 'Diseñadora gráfica 🎨 | Yoga lover 🧘‍♀️ | Foodie empedernida 🍕',
        photos: [
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800',
          'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=800',
        ],
        location: UserLocation(
          country: 'Argentina',
          state: 'Buenos Aires',
          city: 'Palermo',
        ),
        distance: 1.2,
        interests: ['Diseño', 'Yoga', 'Comida', 'Arte'],
        gender: 'Mujer',
        sexualOrientation: 'Heterosexual',
        job: UserJob(
          title: 'Arquitecta',
          company: 'Estudio A',
          education: 'Universitario',
        ),
        lifestyle: UserLifestyle(
          drink: 'Ocasionalmente',
          smoke: 'No',
          workout: 'Diario',
          zodiac: 'Virgo',
          height: '170',
        ),
        searchIntent: 'Algo casual',
      ),
      UserModel(
        id: '3',
        uid: 'user3',
        name: 'Martina',
        age: 23,
        bio:
            'Bailarina profesional 💃 Me encanta la música, el teatro y conocer gente nueva',
        photos: [
          'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=800',
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800',
        ],
        location: UserLocation(
          country: 'Argentina',
          state: 'Buenos Aires',
          city: 'Recoleta',
        ),
        distance: 3.8,
        interests: ['Baile', 'Música', 'Teatro', 'Fitness'],
        gender: 'Mujer',
        sexualOrientation: 'Bisexual',
        job: UserJob(
          title: 'Bailarina',
          company: 'Teatro Colón',
          education: 'Terciario',
        ),
        lifestyle: UserLifestyle(
          drink: 'Nunca',
          smoke: 'No',
          workout: 'Diario',
          zodiac: 'Libra',
          height: '168',
        ),
        searchIntent: 'Amistad',
      ),
      UserModel(
        id: '4',
        uid: 'user4',
        name: 'Camila',
        age: 25,
        bio:
            'Ingeniera de día, gamer de noche 🎮 | Amante de los animales 🐶 | Netflix addict',
        photos: [
          'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=800',
          'https://images.unsplash.com/photo-1502823403499-6ccfcf4fb453?w=800',
        ],
        location: UserLocation(
          country: 'Argentina',
          state: 'Buenos Aires',
          city: 'Belgrano',
        ),
        distance: 4.5,
        interests: ['Gaming', 'Tecnología', 'Mascotas', 'Series'],
        gender: 'Mujer',
        sexualOrientation: 'Heterosexual',
        job: UserJob(
          title: 'Ingeniera',
          company: 'Tech Corp',
          education: 'Universitario',
        ),
        lifestyle: UserLifestyle(
          drink: 'Socialmente',
          smoke: 'Ocasionalmente',
          workout: 'Nunca',
          zodiac: 'Aries',
          height: '162',
        ),
        searchIntent: 'Relación seria',
      ),
      UserModel(
        id: '5',
        uid: 'user5',
        name: 'Lucía',
        age: 27,
        bio:
            'Médica pediatra ❤️ Amo ayudar a los demás. En mi tiempo libre hago senderismo y cocino',
        photos: [
          'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=800',
          'https://images.unsplash.com/photo-1489424731084-a5d8b219a5bb?w=800',
        ],
        location: UserLocation(
          country: 'Argentina',
          state: 'Buenos Aires',
          city: 'Caballito',
        ),
        distance: 5.2,
        interests: ['Medicina', 'Senderismo', 'Cocina', 'Voluntariado'],
        gender: 'Mujer',
        sexualOrientation: 'Heterosexual',
        job: UserJob(
          title: 'Médica',
          company: 'Hospital Italiano',
          education: 'Posgrado',
        ),
        lifestyle: UserLifestyle(
          drink: 'Nunca',
          smoke: 'No',
          workout: 'A veces',
          zodiac: 'Cáncer',
          height: '175',
        ),
        searchIntent: 'Relación seria',
      ),
      UserModel(
        id: '6',
        uid: 'user6',
        name: 'Isabella',
        age: 22,
        bio:
            'Estudiante de arquitectura 🏛️ | Viajera incansable ✈️ | Amante del buen vino 🍷',
        photos: [
          'https://images.unsplash.com/photo-1496440737103-cd596325d314?w=800',
          'https://images.unsplash.com/photo-1479936343636-73cdc5aae0c3?w=800',
        ],
        location: UserLocation(
          country: 'Argentina',
          state: 'Buenos Aires',
          city: 'San Telmo',
        ),
        distance: 2.1,
        interests: ['Arquitectura', 'Viajes', 'Vino', 'Historia'],
        gender: 'Mujer',
        sexualOrientation: 'Heterosexual',
        job: UserJob(
          title: 'Estudiante',
          company: 'UBA',
          education: 'Universitario',
        ),
        lifestyle: UserLifestyle(
          drink: 'Socialmente',
          smoke: 'No',
          workout: 'A veces',
          zodiac: 'Sagitario',
          height: '160',
        ),
        searchIntent: 'Algo casual',
      ),
    ];
  }
}
