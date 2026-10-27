import 'cats.dart';

/// A collectible cat portrait the player can adopt in the shop with
/// Miaudólares (art generated for CodeCats, assets/shopcats/<img>.png).
/// Owned ids live in Progress.badges together with the badges ('c_' ids).
class ShopCat {
  const ShopCat(this.id, this.nameEs, this.nameEn, this.img, this.price,
      [this.rarity = CatRarity.comun]);

  final String id, nameEs, nameEn, img;
  final int price;
  final CatRarity rarity;

  String get file => 'assets/shopcats/$img.png';
}

final List<ShopCat> kShopCats = [
  // Hats
  const ShopCat(
      'c_mago', 'Mago Bigotes', 'Whisker Wizard', 'c01', 90, CatRarity.epico),
  const ShopCat(
      'c_pirata', 'Pirata Tuerto', 'One-Eye Pirate', 'c02', 60, CatRarity.raro),
  const ShopCat('c_chef', 'Chef Miau', 'Chef Mew', 'c03', 40),
  const ShopCat(
      'c_rey', 'Rey Catoncito', 'King Kitty', 'c04', 120, CatRarity.legendario),
  const ShopCat('c_gorrito', 'Siamés Gorrito', 'Beanie Siamese', 'c05', 35),
  const ShopCat('c_mariachi', 'Michi Mariachi', 'Mariachi Cat', 'c06', 60,
      CatRarity.raro),
  const ShopCat('c_gorra', 'Beto Gorra', 'Cap Cat', 'c07', 30),
  const ShopCat('c_fiesta', 'Festi Gato', 'Party Cat', 'c08', 45),
  const ShopCat(
      'c_graduado', 'Gato Graduado', 'Grad Cat', 'c09', 80, CatRarity.epico),
  // Glasses
  const ShopCat('c_nono', 'Ñoño Lentes', 'Nerdy Specs', 'c10', 35),
  const ShopCat(
      'c_corbaton', 'Don Moño', 'Bow-Tie Boss', 'c11', 55, CatRarity.raro),
  const ShopCat(
      'c_estrella', 'Estrella Pop', 'Pop Star', 'c12', 70, CatRarity.raro),
  const ShopCat(
      'c_monoculo', 'Monóculo Fancy', 'Sir Monocle', 'c13', 60, CatRarity.raro),
  const ShopCat('c_3d', 'Cine 3D', 'Movie Cat', 'c14', 45),
  const ShopCat(
      'c_aviador', 'Aviador Moto', 'Biker Goggles', 'c15', 55, CatRarity.raro),
  const ShopCat('c_profe', 'Profe Plumita', 'Professor Cat', 'c16', 50),
  const ShopCat('c_fan', 'Corazón Fan', 'Heart Eyes', 'c17', 40),
  const ShopCat(
      'c_hacker', 'Hacker Pixel', 'Pixel Hacker', 'c18', 100, CatRarity.epico),
  // Costumes
  const ShopCat(
      'c_super', 'Super Miau', 'Super Mew', 'c19', 100, CatRarity.epico),
  const ShopCat(
      'c_astro', 'Astronauta Buzz', 'Astro Cat', 'c20', 110, CatRarity.epico),
  const ShopCat(
      'c_caballero', 'Sir Caballero', 'Knight Cat', 'c21', 80, CatRarity.epico),
  const ShopCat('c_dragon', 'Dragón Fafafa', 'Cat-Dragon', 'c22', 120,
      CatRarity.legendario),
  const ShopCat('c_capucha', 'Capucha Chill', 'Hoodie Cat', 'c23', 30),
  const ShopCat(
      'c_ninja', 'Ninja Sombra', 'Shadow Ninja', 'c24', 110, CatRarity.epico),
  const ShopCat('c_vampiro', 'Conde Miaúcula', 'Count Meowcula', 'c25', 80,
      CatRarity.epico),
  const ShopCat(
      'c_buzo', 'Buzo Burbuja', 'Scuba Cat', 'c26', 60, CatRarity.raro),
  const ShopCat('c_bufanda', 'Abrigo Nieve', 'Snow Scarf', 'c27', 35),
  // Tech & gaming
  const ShopCat('c_dj', 'DJ Orejas', 'DJ Ears', 'c28', 70, CatRarity.raro),
  const ShopCat('c_vr', 'Gato VR', 'VR Cat', 'c29', 110, CatRarity.epico),
  const ShopCat(
      'c_teclado', 'Teclado RGB', 'RGB Keyboard', 'c30', 75, CatRarity.raro),
  const ShopCat(
      'c_thug', 'Thug Pixel', 'Pixel Thug', 'c31', 75, CatRarity.raro),
  const ShopCat(
      'c_robot', 'Robot Antena', 'Robo Cat', 'c32', 85, CatRarity.epico),
  const ShopCat('c_dev', 'Dev Laptop', 'Laptop Dev', 'c33', 65, CatRarity.raro),
  const ShopCat('c_zen', 'Auriculares Zen', 'Zen Earbuds', 'c34', 40),
  const ShopCat(
      'c_caster', 'Comentarista Pro', 'Pro Caster', 'c35', 65, CatRarity.raro),
  const ShopCat(
      'c_gamer', 'Gamer LED', 'LED Gamer', 'c36', 115, CatRarity.epico),
  // Food
  const ShopCat('c_pescador', 'Pescador Félix', 'Fisher Felix', 'c37', 45),
  const ShopCat('c_pizza', 'Pizza Panza', 'Pizza Belly', 'c38', 50),
  const ShopCat(
      'c_cafe', 'Grumpy Café', 'Grumpy Coffee', 'c39', 55, CatRarity.raro),
  const ShopCat('c_helado', 'Helado Tornado', 'Ice-Cream Cat', 'c40', 45),
  const ShopCat(
      'c_sushi', 'Sushi Snob', 'Sushi Snob', 'c41', 60, CatRarity.raro),
  const ShopCat(
      'c_dona', 'Dona Sorpresa', 'Donut Surprise', 'c42', 55, CatRarity.raro),
  const ShopCat('c_cookie', 'Cookie Chanchi', 'Cookie Cat', 'c43', 40),
  const ShopCat('c_torta', 'Torta Babas', 'Cake Drool', 'c44', 45),
  const ShopCat('c_bebe', 'Biberón Bebé', 'Baby Bottle', 'c45', 35),
];
