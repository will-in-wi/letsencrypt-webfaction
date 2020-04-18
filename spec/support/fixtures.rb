# frozen_string_literal: true

def fixture(filename)
  FIXTURE_DIR.join(filename).read
end
