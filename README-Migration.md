# Dropping Management / Sale / Tax Tables

After removing Management, Sale, and Tax Collection code from the backend, drop the corresponding database tables so the schema matches the clean solution.

## Steps

1. **Back up your database** before running any drop script.

2. **Run the PostgreSQL script:** `DB Scripts/DropManagementSaleTaxTables-PostgreSQL.sql`

3. **Run the script** against the **main app database** (the one used by `MediCubes.WebApi` / AppDbContext). Do **not** run it against the Auth database.

4. If you get **foreign key** errors: use `DROP TABLE ... CASCADE;` to drop dependent objects, or drop tables in dependency order.

5. **Optional – EF Core migration:** If you use EF Core migrations, you can add a new migration after this cleanup. The migration will see that those entities are gone and can generate the same drops (or you can keep the DB as-is and add a migration that does nothing / just records the current model).

## Table names

If your tables use different names (e.g. different schema or naming), edit the script and replace the table names with the ones you see in your database.
