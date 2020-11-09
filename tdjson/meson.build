tdlib = declare_dependency(

	sources: ['tdjson.vapi','tdlog.vapi'],
    dependencies: [

    	dependency('Td', modules: [
			'Td::tdjson',
			'Td::tdcore',
			'Td::tdutils',
			'Td::tdsqlite'
    	], method:'cmake'),
    	meson.get_compiler('cpp').find_library('stdc++'),

    ]

)
