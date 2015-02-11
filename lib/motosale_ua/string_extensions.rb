module StringExtensions
  def strip
    super.gsub "\u00a0", ""
  end
end

class String
  prepend StringExtensions
end

