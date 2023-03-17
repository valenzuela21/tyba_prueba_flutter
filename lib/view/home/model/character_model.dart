class CharacterModel {
  CharacterModel({
    this.id,
    this.name,
    this.photoURL,
    this.description,
  });

  int? id;
  String? name;
  String? photoURL;
  String? description;

  @override
  String toString() {
    return 'CharacterModel{id: $id, name: $name, photoURL: $photoURL, description: $description}';
  }
}
