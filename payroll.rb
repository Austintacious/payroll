require 'CSV'

class CsvReader
  def initialize(file)
    @file = file
  end

  def parse
    temp_array = []
    CSV.foreach(@file, headers:true) do |row|
      temp_array << row
    end
    temp_array
  end
end


class Employee
  @@tax = 0.3

  attr_reader :name, :net_pay

  def initialize(row)
    @name = row["name"]
    @type = row["type"]
    @salary = row["salary"]
    @commibonus = row["commibonus"]
    @quota = row["quota"]
  end

  def calculate_monthly_salary
    format_number(@salary.to_f/12)
  end

  def calculate_net_pay
    format_number(calculate_monthly_salary.to_f - (calculate_monthly_salary.to_f * @@tax))
  end

  def format_number(num)
    sprintf('%0.2f', num)
  end

end

class Owner < Employee
  @monthly_quota = 250000

  def find_gross_sale_value(file)
    sales_data = CsvReader.new(file).parse
    @gross_sales = []
    sales_data.each do |row|
      @gross_sales << row["gross_sale_value"].to_i
    end
    @gross_sales.reduce(:+)
  end

  def check_bonus?(amount)
    amount > @monthly_quota
  end

end

class Commission < Employee
  def initialize
    determine_commission
  end
  
  def determine_commission
    
  end 
end

class Quota < Employee
end

class Payroll

  attr_reader :employees

  def initialize(sales,employeesfile)
    @sales = sales
    @employeesfile = employeesfile
    @employees = {}
  end

  def populate_employees
    employees = CsvReader.new(@employeesfile).parse
    employees.each do |row|
      var = row["type"]

      if var == "owner"
        @employees[row["name"]] = Owner.new(row)
      elsif var == "commission"
        @employees[row["name"]] = Commission.new(row)
      elsif var == "quota"
        @employees[row["name"]] = Quota.new(row)
      else
        @employees[row["name"]] = Employee.new(row)
      end
    end
    @employees
  end

  def list_employees
    puts @employees.keys
  end

  def find_monthly_gross
    @employees["Charles Burns"].find_gross_sale_value(@sales)
  end

  def monthly_salary(employee)
    monthly_salary unless @employees.include?(employee)
    puts "***#{@employees[employee].name}***"
    puts "Gross Salary: $#{@employees[employee].calculate_monthly_salary}"
    puts "Net Pay: $#{@employees[employee].calculate_net_pay}"
    puts "***"
  end
end

powerplant = Payroll.new('sales_data.csv','employees.csv')
powerplant.populate_employees
powerplant.list_employees
puts '~~~~~~~~~~~~~~~'
puts powerplant.find_monthly_gross
puts powerplant.monthly_salary("Jimmy McMahon")