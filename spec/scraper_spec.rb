require 'spec_helper'

describe MotosaleUa::Scraper do
  describe "#fetch_list" do
    it "finds items correctly in the *actual* HTML" do
      p = MotosaleUa::Scraper.new

      list = p.fetch_list 1

      list.count.should == 10
    end

    it "parses items in a page" do
      Net::HTTP.stub(:get).and_return File.read("./spec/assets/list.html").force_encoding("WINDOWS-1251")

      m = MotosaleUa::Scraper.new

      list = m.fetch_list nil

      list.count.should == 10

      list.first.should == {
        :make               => "YAMAHA",
        :model_name         => "XVS 950 A Midnight Star",
        :mileage            => "15000",
        :year_built         => "2010",
        :papers             => "Стоит на укр.учете",
        :link               => "yamaha/XVS_950_A_Midnight_Star_375006.html",
        :price              => "10500 $",
        :location           => "Одесса",
        :uin                => 375006,
        :date_published     => "07.02.2015",
        :ms_photo_file_name => "k4hcftndsmvdvwh69apg.jpg"
      }
    end
  end
end
