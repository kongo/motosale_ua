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

      list.first.should == {:make=>"HONDA", :model_name=>"XR 250 R", :mileage=>"28700", :year_built=>"2001", :papers=>"Стоит на укр.учете", :link=>"honda/XR_250_R_376461.html", :price=>"3050 $", :location=>"Днепропетровск", :uin=>376461, :date_published=>"19.02.2015", :ms_photo_file_name=>"aeuwfccnpm9uqdvqsxrn.jpg"}
    end
  end

  describe "#fetch_item_details" do
    it "parses details page" do
      Net::HTTP.stub(:get).and_return File.read("./spec/assets/item.html").force_encoding("WINDOWS-1251")

      item_details = MotosaleUa::Scraper.new.fetch_item_details "http://www.motosale.com.ua/suzuki/DR-Z_400_375743.html"

      item_details.should == {
        :link           => "http://www.motosale.com.ua/suzuki/DR-Z_400_375743.html",
        :make           => "SUZUKI",
        :model_name     => "DR-Z 400",
        :topic          => "свіжий",
        :motorcycle     => "SUZUKI - DR-Z 400",
        :vehicle_type   => "Эндуро",
        :papers         => "Модель не для дорог общего пользования",
        :mileage        => "17200 км",
        :year_built     => "2007 г.",
        :displacement   => "400 cm3",
        :place          => "Ивано-Франковск",
        :message        => "стан як на фото без торга",
        :price          => "3450$",
        :phone          => "0967348228",
        :date_published => "13-02-2015"
      }

    end
  end

  describe "#fetch_item_photos_urls" do
    it "parses photos page" do
      Net::HTTP.stub(:get).and_return File.read("./spec/assets/gall.html").force_encoding("WINDOWS-1251")

      MotosaleUa::Scraper.new.fetch_item_photos_urls(375756).should == [
        "http://www.motosale.com.ua/big/mhe9t5nugprky5n4ufd7.jpg",
        "http://www.motosale.com.ua/big/zsz7mbkhageknde4thae.jpg",
        "http://www.motosale.com.ua/big/7tkpcsenak2v4sa63f6w.jpg",
        "http://www.motosale.com.ua/big/h5s7cdzqh9udh6hmk4ve.jpg",
        "http://www.motosale.com.ua/big/u9mccsaat9gfghhtrrpd.jpg"
      ]
    end
  end

end
