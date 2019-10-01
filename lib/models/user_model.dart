class User {
  String username;
  String firstName;
  String lastName;
  String location;
  String avatar;

  User(
      {this.username,
      this.firstName,
      this.lastName,
      this.location,
      this.avatar});

  String fullName() => "$firstName $lastName";

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        username: json['email'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        location: json['location']!=null ? json['location']['name']: "",
        avatar: json["picture"]["data"]["url"]);
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'first_name': firstName,
    'last_name': lastName,
    'location': location,
    'avatar': avatar
  };
}
