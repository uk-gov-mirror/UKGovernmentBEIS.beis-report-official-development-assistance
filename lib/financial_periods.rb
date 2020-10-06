module FinancialPeriods
  FINANCIAL_QUARTERS = (1..4).to_a

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

  def self.current_financial_quarter_string
    financial_quarter_from_date(Date.today).to_s
  end

  def self.current_financial_year_string
    financial_year_from_date(Date.today).to_s
  end

  def self.next_ten_financial_years
    this_year = Date.today.year
    tenth_year = this_year + 9
    (this_year..tenth_year).step.to_a
  end

  def self.start_date_from_financial_quarter_and_year(financial_quarter, financial_year)
    first_month_of_quarter = {"1": "April", "2": "July", "3": "October", "4": "Janurary"}
    year_of_quarter = financial_quarter == "4" ? financial_year.to_i + 1 : financial_year
    "#{first_month_of_quarter[financial_quarter.to_sym]} #{year_of_quarter}".to_date.beginning_of_quarter
  end

  def self.end_date_from_financial_quarter_and_year(financial_quarter, financial_year)
    last_month_of_quarter = {"1": "June", "2": "September", "3": "December", "4": "March"}
    year_of_quarter = financial_quarter == "4" ? financial_year.to_i + 1 : financial_year
    "#{last_month_of_quarter[financial_quarter.to_sym]} #{year_of_quarter}".to_date.end_of_quarter
  end
end
