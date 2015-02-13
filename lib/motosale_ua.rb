require "motosale_ua/version"
require "nokogiri"
require "motosale_ua/string_extensions"

module MotosaleUa

  class Scraper
    require 'net/http'

    ENDPOINT = "www.motosale.com.ua"
    PER_PAGE = 10
    VEHICLE_TYPES_BY_INDEX = {
      :classic      => "%CA%EB%E0%F1%F1%E8%EA",
      :neoclassic   => "%CD%E5%EE%EA%EB%E0%F1%F1%E8%EA",
      :chopper      => "%D7%EE%EF%EF%E5%F0",
      :sport        => "%D1%EF%EE%F0%F2",
      :sporttourist => "%D1%EF%EE%F0%F2-%F2%F3%F0%E8%F1%F2",
      :tourist      => "%D2%F3%F0%E8%F1%F2",
      :enduro       => "%DD%ED%E4%F3%F0%EE",
      :cross        => "%CA%F0%EE%F1%F1",
      :pitbike      => "%CF%E8%F2%E1%E0%E9%EA",
      :supermoto    => "%D1%F3%EF%E5%F0-%EC%EE%F2%EE",
      :trial        => "%D2%F0%E8%E0%EB-%EC%EE%F2%EE",
      :scooter      => "%D1%EA%F3%F2%E5%F0",
      :maxiscooter  => "%CC%E0%EA%F1%E8-%D1%EA%F3%F2%E5%F0",
      :custom       => "%CA%E0%F1%F2%EE%EC",
      :trike        => "%D2%F0%E0%E9%EA",
      :quadracycle  => "%CA%E2%E0%E4%F0%EE%F6%E8%EA%EB",
      :watercraft   => "%C3%E8%E4%F0%EE%F6%E8%EA%EB",
      :snowmobile   => "C%ED%E5%E3%EE%F5%EE%E4",
      :all           => ""
    }

    def fetch_list(page_num, vehicle_type_index = :all)
      doc = Nokogiri::HTML fetch_list_page_body(page_num, vehicle_type_index)
      items = doc.xpath('//body/table[1]/tr[2]/td[1]/table[1]/tr[1]/td[3]/table[1]/tr[1]/td[1]/div[4]/div[not(@id) and not(@class)]')

      items.map do |item|
        brand_model = item.xpath("div[2]/table[1]/tbody[1]/tr[1]/td[1]/table[1]/tr[3]/td/span/strong").first.content.strip
        make        = brand_model.split(" - ").first

        {
          make:           make,
          model_name:     brand_model[(make.length + 3)..-1],
          mileage:        item.xpath("div[2]/table[1]/tbody[1]/tr[1]/td[1]/table[1]/tr[5]/td").first.children[1].content.strip.gsub(' км,', ''),
          year_built:     item.xpath("div[2]/table[1]/tbody[1]/tr[1]/td[1]/table[1]/tr[5]/td").first.children[3].content.strip,
          papers:         item.xpath("div[2]/table[1]/tbody[1]/tr[1]/td[1]/table[1]/tr[4]/td").first.children[1].content.strip,
          link:           item.xpath("div[2]/table[1]/tbody[1]/tr[1]/td[1]/table/tr/td/a").first.attributes["href"].value,
          price:          item.xpath("div[1]/table/tbody/tr/td[2]/b").first.content.strip,
          location:       item.xpath("div[1]/table/tbody/tr/td[2]/font").first.content.strip,
          uin:            item.xpath("div[2]/table[2]/tbody/tr/td").first.children[2].content[4..-1].to_i,
          date_published: item.xpath("div[2]/table[2]/tbody/tr/td").first.children[1].content.strip.strip,
          ms_photo_file_name: item.xpath("div[2]/table[1]/tbody[1]/tr[1]/td[1]/table[1]/tr[1]/td/a/img").first.attributes["src"].value[8..-1]
        }
      end
    end

    def fetch_item_details(link)
      page = Net::HTTP.get ENDPOINT, link
      doc  = Nokogiri::HTML page
      e    = doc.xpath '//body/table[1]/tr[2]/td[1]/table[1]/tr[1]/td[3]/table[1]/tr[1]/td[1]/div[4]/div[2]/table[1]'
      {
        link:           link,
        make:           e.xpath('//tr[7]/td[2]').children.first.content.strip.split(' - ', 2).first,
        model_name:     e.xpath('//tr[7]/td[2]').children.first.content.strip.split(' - ', 2).last,
        topic:          e.xpath('//tr[6]/td[2]').children.first.content.strip,
        motorcycle:     e.xpath('//tr[7]/td[2]').children.first.content.strip,
        vehicle_type:   e.xpath('//tr[8]/td[2]').children.first.content.strip,
        papers:         e.xpath('//tr[9]/td[2]').children.last.content,
        mileage:        e.xpath('//tr[10]/td[2]').children.first.content.strip,
        year_built:     e.xpath('//tr[11]/td[2]').children.first.content.strip,
        displacement:   e.xpath('//tr[12]/td[2]').children.first.content.strip,
        place:          e.xpath('//tr[15]/td[2]').children.first.content.strip,
        message:        e.xpath('//tr[16]/td[2]').children.reject {|r| r.attributes['id'].value == 'anti_parser' rescue false }.map(&:content).join('').strip,
        price:          e.xpath('//tr[17]/td[2]').children.first.content.strip,
        phone:          e.xpath('//tr[18]/td[2]').children.last.content.strip,
        date_published: e.xpath('//tr[19]/td[1]/font[2]').first.content
      }
    end

    def fetch_item_photos_urls(uin)
      page = Net::HTTP.get ENDPOINT, "/gall.php?mID=#{uin}"
      doc  = Nokogiri::HTML page
      doc.css('img.foto').map {|x| x.attributes['src'].value }
    end

    private

    def fetch_list_page_body(page_num = 1, vehicle_type_index = :all)
      offset       = (page_num ? ((page_num - 1) * PER_PAGE).to_s : "show_all")
      vehicle_type = VEHICLE_TYPES_BY_INDEX[vehicle_type_index]

      page_addr = "/index.php?search=moto&model=&price%5Bmin%5D=&price" +
        "%5Bmax%5D=&city=&in%5Bmin%5D=&in%5Bmax%5D=&run=&v=&type_obj=1&offset=" +
        offset + "&moto[]=" + vehicle_type

      Net::HTTP.get ENDPOINT, page_addr
    end
  end

end
