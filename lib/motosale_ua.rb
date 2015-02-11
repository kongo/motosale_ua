require "motosale_ua/version"

module MotosaleUa

  class Scraper
    require 'net/http'

    ENDPOINT = "www.motosale.com.ua"
    PER_PAGE = 10
    VEHICLE_TYPES_BY_INDEX = {
      :classic      => "%CA%EB%E0%F1%F1%E8%EA".html_safe,
      :neoclassic   => "%CD%E5%EE%EA%EB%E0%F1%F1%E8%EA".html_safe,
      :chopper      => "%D7%EE%EF%EF%E5%F0".html_safe,
      :sport        => "%D1%EF%EE%F0%F2".html_safe,
      :sporttourist => "%D1%EF%EE%F0%F2-%F2%F3%F0%E8%F1%F2".html_safe,
      :tourist      => "%D2%F3%F0%E8%F1%F2".html_safe,
      :enduro       => "%DD%ED%E4%F3%F0%EE".html_safe,
      :cross        => "%CA%F0%EE%F1%F1".html_safe,
      :pitbike      => "%CF%E8%F2%E1%E0%E9%EA".html_safe,
      :supermoto    => "%D1%F3%EF%E5%F0-%EC%EE%F2%EE".html_safe,
      :trial        => "%D2%F0%E8%E0%EB-%EC%EE%F2%EE".html_safe,
      :scooter      => "%D1%EA%F3%F2%E5%F0".html_safe,
      :maxiscooter  => "%CC%E0%EA%F1%E8-%D1%EA%F3%F2%E5%F0".html_safe,
      :custom       => "%CA%E0%F1%F2%EE%EC".html_safe,
      :trike        => "%D2%F0%E0%E9%EA".html_safe,
      :quadracycle  => "%CA%E2%E0%E4%F0%EE%F6%E8%EA%EB".html_safe,
      :watercraft   => "%C3%E8%E4%F0%EE%F6%E8%EA%EB".html_safe,
      :snowmobile   => "C%ED%E5%E3%EE%F5%EE%E4".html_safe,
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
      e    = doc.xpath '//body/table[1]/tr[2]/td[1]/table[1]/tr[1]/td[3]/table[1]/tr[1]/td[1]/div[3]/div[3]/table[1]'
      {
        mileage:      e.xpath('//tr[10]/td[2]').children.first.content.strip,
        displacement: e.xpath('//tr[12]/td[2]').children.first.content.strip,
        message:      e.xpath('//tr[14]/td[2]').children.reject {|r| r.attributes['id'].value == 'anti_parser' rescue false }.map(&:content).join(''),
        author_name:  e.xpath('//tr[16]/td[2]').children[0].content,
        phone:        e.xpath('//tr[16]/td[2]').children[3].content.strip,
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
