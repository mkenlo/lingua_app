class User{

  String username;
  String firstName;
  String lastName;
  String location;
  String avatar;


  User({this.username, this.firstName, this.lastName, this.location,
      this.avatar});

  String fullName() => "$firstName $lastName";

}