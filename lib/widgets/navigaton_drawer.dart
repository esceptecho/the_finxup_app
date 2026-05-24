import 'package:flutter/material.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/widgets/dynamic_profile_screen.dart';
import 'package:the_finxup_app/widgets/quick_note.dart';

class NavigatonDrawer extends StatelessWidget {
  const NavigatonDrawer({super.key});

  @override
  Widget build(BuildContext context) => Drawer(
    child: SingleChildScrollView(
      child: Column(
        children: <Widget>[buildHeader(context), buildMenuItems(context)],
      ),
    ),
  );
  Widget buildHeader(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DynamicProfileScreen(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          bottom: 24,
        ),
        color: Colors.transparent,
        child: Column(
          children: [
            Hero(
              tag: 'assets/arees_profile',
              child: CircleAvatar(
                radius: 52,
                backgroundImage: AssetImage('assets/arees_profile.jpeg'),
              ),
            ),
            Text(
              'Arees Angulo',
              style: TextStyle(fontSize: 28, color: AppThemeHSL.textPrimary),
            ),
            Text(
              'arees@brang.com',
              style: TextStyle(fontSize: 16, color: AppThemeHSL.textHint),
            ),
          ],
        ),
      ),
    ),
  );
  Widget buildMenuItems(BuildContext context) => Container(
    padding: EdgeInsets.all(24),
    child: Wrap(
      runSpacing: 16, // vertical space
      children: [
        ListTile(
          leading: Icon(Icons.home_outlined, color: AppThemeHSL.textPrimary),
          title: Text('Home', style: TextStyle(color: AppThemeHSL.textPrimary)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => Placeholder()),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.favorite_border, color: AppThemeHSL.textPrimary),
          title:  Text(
            'Favorites',
            style: TextStyle(color: AppThemeHSL.textPrimary),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Placeholder(),
              ),
            );
          },
        ),
        ListTile(
          leading:  Icon(
            Icons.attach_money_outlined,
            color: AppThemeHSL.textPrimary,
          ),
          title: Text(
            'Transacciones',
            style: TextStyle(color: AppThemeHSL.textPrimary),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Placeholder(),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.update, color: AppThemeHSL.textPrimary),
          title: Text(
            'Updates',
            style: TextStyle(color: AppThemeHSL.textPrimary),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Placeholder(
                  color: AppThemeHSL.divider,
                  child: Icon(Icons.update, color: AppThemeHSL.textPrimary),
                ),
              ),
            );
          },
        ),
        Divider(color: AppThemeHSL.divider),
        ListTile(
          leading: Icon(
            Icons.grid_view_outlined,
            color: AppThemeHSL.textPrimary,
          ),
          title: Text(
            'Notas',
            style: TextStyle(color: AppThemeHSL.textPrimary),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => NotesGridScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.notifications, color: AppThemeHSL.textPrimary),
          title: Text(
            'Notifications',
            style: TextStyle(color: AppThemeHSL.textPrimary),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Placeholder(
                  color: AppThemeHSL.textHint,
                  child: Icon(
                    Icons.notifications,
                    color: AppThemeHSL.textPrimary,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}
