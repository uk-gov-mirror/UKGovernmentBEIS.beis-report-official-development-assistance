module FinancialPeriods
  def self.financial_quarter_from_date(date)
    month = date.month
    return "4" if (1..3).cover?(month)
    return "1" if (4..6).cover?(month)
    return "2" if (7..9).cover?(month)
    return "3" if (10..12).cover?(month)
  end

  def self.financial_year_from_date(date)
    month = date.month
    year = date.year
    return year.to_s if (4..12).cover?(month)
    return (year - 1).to_s if (1..3).cover?(month)
  end
end
