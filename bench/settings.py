# settings.py
site_configuration = {
    'systems': [
        {
            'name': 'local',
            'descr': 'Local system with two partitions',
            'hostnames': ['.*'],
            'partitions': [
                {
                    'name': 'default',
                    'scheduler': 'local',
                    'launcher': 'local',
                    'environs': ['builtin'],
                },
                {
                    'name': 'ownsem',
                    'scheduler': 'local',
                    'launcher': 'local',
                    'environs': ['builtin'],
                },
                {
                    'name': 'load-only',
                    'scheduler': 'local',
                    'launcher': 'local',
                    'environs': ['builtin'],
                }
            ]
        }
    ],

    'environments': [
        {
            'name': 'builtin',
            'cc': 'gcc',
            'cxx': 'g++',
            'ftn': 'gfortran'
        }
    ],

    'general': [
        {
            'check_search_path': ['tests']
        }
    ]
}
