class OlracIcons {
  static const iconsPath = 'assets/icons';
  static const sharksPath = '$iconsPath/sharks';

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

    // Sharks
    'Squatina australis': '$sharksPath/Australian angelshark Squatina australis.svg',
    'Carcharhinus tilstoni': '$sharksPath/Australian blacktip shark Carcharhinus tilstoni.svg',
    'Alopias superciliosus': '$sharksPath/Bigeye thresher Alopias superciliosus.svg',
    'Hexanchus nakamurai': '$sharksPath/Bigeyed sixgill shark Hexanchus nakamurai.svg',
    'Carcharhinus limbatus': '$sharksPath/Black Tip Shark Carcharhinus limbatus.svg',
    'Carcharhinus melanopterus': '$sharksPath/Blacktip reef shark Carcharhinus melanopterus.svg',
    'Prionace glauca': '$sharksPath/Blue Shark PRIONACE GLAUCA.svg',
    'Hexanchus griseus': '$sharksPath/Bluntnose sixgill shark Hexanchus griseus.svg',
    'Notorynchus cepedianus': '$sharksPath/Broadnose sevengill shark Notorynchus cepedianus.svg',
    'Carcharhinus brachyurus': '$sharksPath/BRONZE WHALER SHARK Carcharhinus brachyurus.svg',
    'Carcharhinus leucas': '$sharksPath/Bull Shark C. leucas.svg',
    'Carcharhinus brachyurus1': '$sharksPath/Copper shark Carcharhinus brachyurus.svg',
    'Carcharhinus obscurus': '$sharksPath/Dusky Shark CARCHARHINUS OBSCURUS.svg',
    'Chlamydoselachus anguineus': '$sharksPath/Frilled shark Chlamydoselachus anguineus.svg',
    'CARCHARIAS TAURUS': '$sharksPath/Grey Nurse Shark CARCHARIAS TAURUS.svg',
    'Carcharhinus amblyrhynchos': '$sharksPath/Grey reef shark Carcharhinus amblyrhynchos.svg',
    'Mustelus antarcticus': '$sharksPath/Gummy Shark MUSTELUS ANTARCTICUS.svg',
    'Sphyrna mokarran': '$sharksPath/Hammerhead Shark SPHYRNA SPP.svg',
    'Sphyrna lewini': '$sharksPath/Hammerhead Shark SPHYRNA SPP.svg',
    'Sphyrna zygaena': '$sharksPath/Hammerhead Shark SPHYRNA SPP.svg',
    'Isurus paucus': '$sharksPath/Longfin mako Isurus paucus.svg',
    'Pristiophorus cirratus': '$sharksPath/Longnose Sawshark Pristiophorus cirratus.svg',
    'Squatina tergocellata': '$sharksPath/Ornate angelshark Squatina tergocellata.svg',
    'Alopias pelagicus': '$sharksPath/Pelagic thresher Alopias pelagicus.svg',
    'SQUALUS MEGALOPS': '$sharksPath/Pike Spurdog SQUALUS MEGALOPS.svg',
    'Heterodontus portusjacksoni': '$sharksPath/Port Jackson Shark HETERODONTUS PORTUSJACKSONI.svg',
    'CARCHARHINUS PLUMBEUS': '$sharksPath/Sandbar Shark CARCHARHINUS PLUMBEUS.svg',
    'Shark1': '$sharksPath/Shark1.svg',
    'Heptranchias perlo': '$sharksPath/Sharpnose sevengill shark Heptranchias perlo.svg',
    'Isurus oxyrinchus': '$sharksPath/Shortfin mako Isurus oxyrinchus.svg',
    'Pristiophorus nudipinnis': '$sharksPath/Shortnose sawshark Pristiophorus nudipinnis.svg',
    'Negaprion acutidens': '$sharksPath/Sicklefin lemon shark Negaprion acutidens.svg',
    'Carcharhinus falciformis': '$sharksPath/Silky shark Carcharhinus falciformis.svg',
    'Carcharhinus albimarginatus': '$sharksPath/Silvertip Shark Carcharhinus albimarginatus.svg',
    'Centrophorus moluccensis': '$sharksPath/Smallfin gulper shark Centrophorus moluccensis.svg',
    'CENTROPHORUS ZEEHAANI': '$sharksPath/Southern Dogfish CENTROPHORUS ZEEHAANI.svg',
    'Carcharhinus brevipinna': '$sharksPath/Spinner shark Carcharhinus brevipinna.svg',
    'Carcharhinus sorrah': '$sharksPath/Spottail Shark Carcharhinus sorrah.svg',
    'Test': '$sharksPath/Test.svg',
    'Galeocerdo cuvier': '$sharksPath/Tiger Shark GALEOCERDO CUVIER.svg',
    'Galeorhinus galeus': '$sharksPath/Tope shark Galeorhinus galeus.svg',
    'RHINCODON TYPUS': '$sharksPath/Whale Shark RHINCODON TYPUS.svg',
    'Furgaleus macki': '$sharksPath/Whiskery Shark FURGALEUS MACKI.svg',
    'CARCHARODON CARCHARIAS': '$sharksPath/White Shark CARCHARODON CARCHARIAS.svg',
    'Eusphyra blochii': '$sharksPath/Winghead shark Eusphyra blochii.svg',
    'Orectolobus ornatus': '$sharksPath/Wobbegong Sharks FAMILY ORECTOLOBIDAE (1).svg',
    'Orectolobus maculatus': '$sharksPath/Wobbegong Sharks FAMILY ORECTOLOBIDAE.svg',
    'Eucrossorhinus dasypogon': '$sharksPath/Wobbegong Sharks FAMILY ORECTOLOBIDAE.svg',
    'STEGOSTOMA FASCIATUM': '$sharksPath/Zebra Shark STEGOSTOMA FASCIATUM.svg',

  };

  static String path(String name) => !_icons.containsKey(name) ? null : _icons[name];
}
