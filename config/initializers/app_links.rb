# Public URL for "Source code" in the app header. Override in production with ENV if needed.
Rails.application.config.x.source_code_url = ENV.fetch("SOURCE_CODE_URL", "https://github.com/mkuipers/scheduler")
