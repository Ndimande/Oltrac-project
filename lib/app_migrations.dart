final List<Map<String, String>> appMigrations = const [
  {
    'name': 'create_json_table',
    'up': 'CREATE TABLE json ( '
        'key TEXT PRIMARY KEY, '
        'json TEXT NOT NULL, '
        'stored_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL'
        ')',
    'down': 'DROP TABLE json'
  },
  {
    'name': 'create_trips_table',
    'up': 'CREATE TABLE trips ( '
        'id INTEGER PRIMARY KEY, '
        'started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, '
        'ended_at TIMESTAMP'
        ')',
    'down': 'DROP TABLE trips'
  },
  {
    'name': 'create_hauls_table',
    'up': 'CREATE TABLE hauls ( '
        'id INTEGER PRIMARY KEY, '
        'started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, '
        'ended_at TIMESTAMP, '
        'trip_id INTEGER NOT NULL, '
        'fishing_method_id INTEGER NOT NULL, '
        'FOREIGN KEY (trip_id) REFERENCES trips (id), '
        'FOREIGN KEY (fishing_method_id) REFERENCES fishing_methods (id)'
        ')',
    'down': 'DROP TABLE hauls'
  },
  {
    'name': 'create_tags_table',
    'up': 'CREATE TABLE tags ( '
        'id INTEGER PRIMARY KEY, '
        'tag_code TEXT NOT NULL, '
        'created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, '
        'haul_id INTEGER NOT NULL, '
        'species_code TEXT NOT NULL, '
        'weight_unit TEXT NOT NULL, ' // grams / ounces
        'length_unit TEXT NOT NULL, ' // cm / inches
        'weight INTEGER NOT NULL, '
        'length INTEGER NOT NULL, '
        'FOREIGN KEY (haul_id) REFERENCES hauls (id)'
        ')',
    'down': 'DROP TABLE tags'
  },
];
