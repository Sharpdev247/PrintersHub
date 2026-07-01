# pg_trgm enables GIN trigram indexes, which power fast ILIKE '%search%' queries
# on title and description without a full pg_search/Elasticsearch setup.
# Required now so the GIN index on listings.title can be created in the same migration batch.
class EnablePgTrgmExtension < ActiveRecord::Migration[8.1]
  def up
    enable_extension "pg_trgm"
  end

  def down
    disable_extension "pg_trgm"
  end
end
