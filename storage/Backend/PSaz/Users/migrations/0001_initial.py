from django.db import migrations

# Your raw SQL commands
RAW_SQL = """
CREATE TABLE CLIENT (
    ID SERIAL PRIMARY KEY,
    Phone_number VARCHAR(11) UNIQUE NOT NULL,
    Referal_code VARCHAR(10) UNIQUE,
    is_vip BOOLEAN DEFAULT FALSE
);
"""

class Migration(migrations.Migration):
    dependencies = [
        ('yourappname', '0001_initial'),  # Depends on previous migrations
    ]

    operations = [
        migrations.RunSQL(
            sql=RAW_SQL,
            reverse_sql="DROP TABLE CLIENT;"  # Optional: SQL to undo the migration
        ),
    ]