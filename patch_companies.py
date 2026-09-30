with open('d:/real_invoice/lib/features/business_profile/presentation/manage_company_list_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

import_statement = "import '../../ads/ad_banner_widget.dart';"
if import_statement not in content:
    content = import_statement + "\n" + content

body_old = """      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: _profiles.isEmpty
            ? _buildEmptyState()
            : ListView.separated("""

body_new = """      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: Column(
          children: [
            const AdBannerWidget(),
            Expanded(
              child: _profiles.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated("""

body_end_old = """                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended("""
body_end_new = """                  },
                ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended("""

content = content.replace(body_old, body_new).replace(body_end_old, body_end_new)

with open('d:/real_invoice/lib/features/business_profile/presentation/manage_company_list_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("manage_company_list_screen patched")