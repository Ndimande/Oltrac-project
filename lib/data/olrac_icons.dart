class OlracIcons {
  static const iconsPath = 'assets/icons';

  static const Map<String, String> _icons = {
    // Fishing methods
    'Beach seine': '$iconsPath/fishing_methods/Oltrace_Beach_Seine.svg',
    'Beam trawl': '$iconsPath/fishing_methods/Oltrace_Beam_Trawl.svg',
    'Boat seine': '$iconsPath/fishing_methods/Oltrace_Purse_Seine.svg',
    'Drift gillnet': '$iconsPath/fishing_methods/Oltrace_Drift_Gillnet.svg',
    'Drifting longline': '$iconsPath/fishing_methods/Oltrace_Drift_Longline.svg',
    'Purse seine': '$iconsPath/fishing_methods/Oltrace_Purse_Seine.svg',
    'Set gillnet (anchored)': '$iconsPath/fishing_methods/Oltrace_Set_Gillnet.svg',
    'Set longline': '$iconsPath/fishing_methods/Oltrace_Set_Longline.svg',

    'Single boat bottom otter trawl': '$iconsPath/fishing_methods/Oltrace_Otter_Trawl.svg',

    // Others
    'Boat': '$iconsPath/Boat.svg',
    'Shark': '$iconsPath/Shark.svg',
  };


  static String path(String name) {
    if (!_icons.containsKey(name)) {
      return null;
    }
    return _icons[name];
  }
}
