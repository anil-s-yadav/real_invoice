import re

with open('lib/features/settings/presentation/user_profile_screen.dart', 'r') as f:
    content = f.read()

if "import '../../reports/bloc/reports_bloc.dart';" not in content:
    content = content.replace("import '../../subscription/presentation/plan_info_screen.dart';", "import '../../subscription/presentation/plan_info_screen.dart';\nimport '../../reports/bloc/reports_bloc.dart';")

content = content.replace("context.read<HomeBloc>().add(const LoadHomeDataEvent());", "context.read<HomeBloc>().add(const LoadHomeDataEvent());\n        context.read<ReportsBloc>().add(const GenerateReportEvent());")

with open('lib/features/settings/presentation/user_profile_screen.dart', 'w') as f:
    f.write(content)
