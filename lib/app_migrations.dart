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
        'start_latitude REAL NOT NULL, '
        'start_longitude REAL NOT NULL, '
        'end_latitude REAL, '
        'end_longitude REAL, '
        'ended_at TIMESTAMP, '
        'is_uploaded INT'
        ')',
    'down': 'DROP TABLE trips'
  },
  {
    'name': 'create_hauls_table',
    'up': 'CREATE TABLE hauls ( '
        'id INTEGER PRIMARY KEY, '
        'started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, '
        'ended_at TIMESTAMP, '
        'start_latitude REAL NOT NULL, '
        'start_longitude REAL NOT NULL, '
        'end_latitude REAL, '
        'end_longitude REAL, '
        'trip_id INTEGER NOT NULL, '
        'fishing_method_id INTEGER NOT NULL, '
        'FOREIGN KEY (trip_id) REFERENCES trips (id) '
        ')',
    'down': 'DROP TABLE hauls'
  },
  {
    'name': 'create_landings_table',
    'up': 'CREATE TABLE landings ( '
        'id INTEGER PRIMARY KEY, '
        'created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, '
        'haul_id INTEGER NOT NULL, '
        'species_code TEXT NOT NULL, '
        'weight_unit TEXT NOT NULL, ' // grams / ounces
        'length_unit TEXT NOT NULL, ' // cm / inches
        'weight INTEGER NOT NULL, '
        'length INTEGER NOT NULL, '
        'individuals INTEGER NOT NULL DEFAULT 1, '
        'latitude REAL NOT NULL, '
        'longitude REAL NOT NULL, '
        'done_tagging INTEGER DEFAULT 0, '
        'FOREIGN KEY (haul_id) REFERENCES hauls (id)'
        ')',
    'down': 'DROP TABLE landings'
  },
  {
    'name': 'create_products_table',
    'up': 'CREATE TABLE products( '
        'id INTEGER PRIMARY KEY, '
        'tag_code TEXT NOT NULL, '
        'product_type_id NOT NULL, '
        'packaging_type_id NOT NULL, '
        'created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, '
        'latitude REAL NOT NULL, '
        'longitude REAL NOT NULL, '
        'weight INTEGER, '
        'FOREIGN KEY (landing_id) REFERENCES landings (id)'
        ')',
    'down': 'DROP TABLE products'
  },
  {
    'name': 'create_product_has_landings',
    'up':'CREATE TABLE product_has_landings( '
      'landing_id INTEGER, '
      'product_id INTEGER, '
      'FOREIGN KEY (landing_id) REFERENCES landings (id), '
      'FOREIGN KEY (product_id) REFERENCES products (id) '
      ')',
    'down': 'DROP TABLE product_has_landings'
  }
];
