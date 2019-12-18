class UserSettings {
  final bool darkMode;
  final bool allowMobileData;
  final bool uploadAutomatically;

  UserSettings({this.darkMode, this.allowMobileData, this.uploadAutomatically});

  UserSettings copyWith({bool darkMode, bool allowMobileData, bool uploadAutomatically}) {
    return UserSettings(
      darkMode: darkMode ?? this.darkMode,
      allowMobileData: allowMobileData ?? this.allowMobileData,
      uploadAutomatically: uploadAutomatically ?? this.uploadAutomatically,
    );
  }
}
