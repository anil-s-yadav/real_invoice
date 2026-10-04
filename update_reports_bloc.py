import re

with open('lib/features/reports/bloc/reports_bloc.dart', 'r') as f:
    content = f.read()

# Add to fields
content = content.replace(
    'final String? businessGstin;',
    'final String? businessGstin;\n  final bool forceRefresh;'
)
# Add to constructor
content = content.replace(
    'this.businessGstin,\n  });',
    'this.businessGstin,\n    this.forceRefresh = false,\n  });'
)
# Add to props
content = content.replace(
    'businessGstin,\n  ];',
    'businessGstin,\n    forceRefresh,\n  ];'
)
# Update logic
content = content.replace(
    'if (state is ReportsLoaded) {',
    'if (state is ReportsLoaded && !event.forceRefresh) {'
)

with open('lib/features/reports/bloc/reports_bloc.dart', 'w') as f:
    f.write(content)
