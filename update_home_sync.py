import re

with open('lib/features/home/presentation/home_screen.dart', 'r') as f:
    content = f.read()

if "import '../../reports/bloc/reports_bloc.dart';" not in content:
    content = content.replace("import '../../subscription/bloc/subscription_state.dart';", "import '../../subscription/bloc/subscription_state.dart';\nimport '../../reports/bloc/reports_bloc.dart';")

content = content.replace("context.read<HomeBloc>().add(const LoadHomeDataEvent());", "context.read<HomeBloc>().add(const LoadHomeDataEvent());\n                context.read<ReportsBloc>().add(const GenerateReportEvent());")

with open('lib/features/home/presentation/home_screen.dart', 'w') as f:
    f.write(content)
