class TimeWindowParser
  Result = Struct.new(:ok?, :start_minute, :end_minute, :error, keyword_init: true)

  TIME_PAT  = /(\d{1,2})(?::(\d{2}))?\s*(am?|pm?)?/i
  SEP_PAT   = /\s*(?:-|–|—|\bto\b)\s*/i
  WINDOW_RE = /\A\s*#{TIME_PAT}#{SEP_PAT}#{TIME_PAT}\s*\z/i

  # "330pm" / "1030am" style (no colon) — not preceded by another digit or ":" (avoids touching "14:30pm").
  COMPACT_MERIDIEM = /(?<![:\d])(\d{3,4})\s*(am|pm)\b/i

  def self.parse(input)
    new(input).parse
  end

  def initialize(input)
    @input = input.to_s
  end

  def parse
    normalized = normalize_compact_meridiem(@input)
    m = WINDOW_RE.match(normalized)
    return err("Could not parse time window — try something like \"2pm-4pm\" or \"14:00-16:00\"") unless m

    start_h, start_m, start_suffix = m[1].to_i, (m[2] || "0").to_i, m[3]
    end_h,   end_m,   end_suffix   = m[4].to_i, (m[5] || "0").to_i, m[6]

    return err("Minutes must be 0-59") if start_m > 59 || end_m > 59

    end_suffix_norm   = normalize_suffix(end_suffix)
    start_suffix_norm = normalize_suffix(start_suffix) || end_suffix_norm

    start_min = to_minutes(start_h, start_m, start_suffix_norm)
    end_min   = to_minutes(end_h, end_m, end_suffix_norm)

    return err("Hour out of range") if start_min.nil? || end_min.nil?
    return err("End time must be after start time") if end_min <= start_min

    Result.new(ok?: true, start_minute: start_min, end_minute: end_min, error: nil)
  end

  private

  def normalize_compact_meridiem(str)
    str.gsub(COMPACT_MERIDIEM) do
      digits = Regexp.last_match(1)
      suf = Regexp.last_match(2)
      body = expand_digits_meridiem(digits)
      body ? "#{body}#{suf.downcase}" : Regexp.last_match(0)
    end
  end

  # Returns "H:MM" (24h-style clock face only; am/pm is appended by caller) or nil if not a valid compact token.
  def expand_digits_meridiem(digits)
    case digits.length
    when 3
      h = digits[0].to_i
      m = digits[1..2].to_i
      return nil if h < 1 || h > 9 || m > 59
    when 4
      h = digits[0..1].to_i
      m = digits[2..3].to_i
      return nil if h < 1 || h > 12 || m > 59
    else
      return nil
    end
    "#{h}:#{format('%02d', m)}"
  end

  def normalize_suffix(s)
    return nil if s.nil? || s.empty?
    s.downcase.start_with?("p") ? :pm : :am
  end

  def to_minutes(h, m, suffix)
    if suffix == :pm
      h = h == 12 ? 12 : h + 12
    elsif suffix == :am
      h = h == 12 ? 0 : h
    end
    # 24-hour path (no suffix) — validate range
    return nil if h > 23 || h < 0
    h * 60 + m
  end

  def err(msg)
    Result.new(ok?: false, start_minute: nil, end_minute: nil, error: msg)
  end
end
