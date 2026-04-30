PaperTrail.config.enabled = true

# Use JSON serializer instead of the default YAML, since the `object` and
# `object_changes` columns on `versions` are stored as JSONB in Postgres.
PaperTrail.serializer = PaperTrail::Serializers::JSON
