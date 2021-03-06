# == Schema Information
#
# Table name: publications
#
#  id                             :integer          not null, primary key
#  name                           :string
#  unit                           :string
#  paper_size                     :string
#  width_in_unit                  :float
#  height_in_unit                 :float
#  left_margin_in_unit            :float
#  top_margin_in_unit             :float
#  right_margin_in_unit           :float
#  bottom_margin_in_unit          :float
#  gutter_in_unit                 :float
#  width                          :float
#  height                         :float
#  left_margin                    :float
#  top_margin                     :float
#  right_margin                   :float
#  bottom_margin                  :float
#  gutter                         :float
#  lines_per_grid                 :integer
#  page_count                     :integer
#  section_names                  :text
#  page_columns                   :text
#  row                            :integer
#  front_page_heading_height      :integer
#  inner_page_heading_height      :integer
#  article_bottom_spaces_in_lines :integer
#  article_line_draw_sides        :text
#  article_line_thickness         :float
#  draw_divider                   :boolean
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#

# front_page_heading_height: height of frontpage heading in lines
# inner_page_heading_height: height of innerpage heading in lines
# page_heading_margin_in_lines: actual heading margin for top positined article
# 393 mm
# 1114.015748031 pt
# 545 mm
# 1544.88189 pt
# 15mm  marging
# 42.519685
#
# 1 mm = 2.834646 point; 1 point = 0.352778 mm

# 1 in = 72 point; 1 point = 0.013889 in
# 1 px = 0.75 point; 1 point = 1.333333 px
class Publication < ApplicationRecord
  has_many :text_styles
  has_many :articles
  has_many :image_templates
  after_create :setup
  before_save :convert_to_pt

  MM2POINT    = 2.834646
  INCH2POINT  = 72
  PX2POINT    = 0.75

  def path
    "#{Rails.root}/public/#{id}"
  end

  def images_path
    "#{Rails.root}/public/images"
  end

  def library_images
    path_array = Dir.glob("#{images_path}/*[.jpg,.pdf]")
    front = "#{Rails.root}/public"
    path_array.map{|p| p.gsub!(front, "")}
  end

  def setup
    system "mkdir -p #{path}" unless File.directory?(path)
  end

  def publication_info_folder
    "/Users/Shared/SoftwareLab/newsman/#{name}"
  end

  def info_yml_path
    publication_info_folder + "/publication_info.yml"
  end

  def publication_info_hash
    info_hash = attributes.dup
    info_hash.shift  # delete id
    info_hash.delete('created_at')    # delete
    info_hash.delete('updated_at')    # delete
    info_hash
  end

  def save_publication_info
    system("mkdir -p #{publication_info_folder}") unless File.directory?(publication_info_folder)
    File.open(info_yml_path,'w'){|f| f.write publication_info_hash.to_yaml}
  end

  def grid_width(page_columns)
    h = (width - left_margin - right_margin)/7
    if page_columns == 7
    elsif page_columns == 6
      h = (width - left_margin - right_margin)/6
    elsif page_columns == 5
      h = (width - left_margin - right_margin)/5
    end
    h
  end

  def grid_height
    (height - top_margin - bottom_margin)/row
  end

  def body_line_height
    grid_height/lines_per_grid
  end

  def body_line_height_in_mm
    (body_line_height/MM2POINT).round(2)
  end

  def front_page_heading_margin
    front_page_heading_height - lines_per_grid
  end

  def x_of_grid_frame(page_columns, grid_frame)
    left_margin + grid_width(page_columns)*grid_frame[0]
  end

  def y_of_grid_frame(page_columns, grid_frame)
    grid_frame[1]*grid_height
  end


  def width_of_grid_frame(page_columns, grid_frame)
    grid_width(page_columns)*grid_frame[2]
  end

  def height_of_grid_frame(page_columns, grid_frame)
    grid_frame[3]*grid_height
  end

  def frame_rect_of_grid_frame(page_columns, grid_frame)
    [x_of_grid_frame(grid_frame), y_of_grid_frame(grid_frame), width_of_grid_frame(grid_frame), height_of_grid_frame(grid_frame)]
  end

  def page_heading_width
    width - left_margin - right_margin
  end

  def page_height
    height - top_margin - bottom_margin
  end

  def page_heading_width_in_mm
    (page_heading_width/MM2POINT).round(2)
  end

  def reload_section_names
    section_names_path = path + "/section_names.rb"
    self.section_names = File.open(section_names_path, 'r'){|f| f.read}
    self.save
  end

  def mm2pt(value)
    value*MM2POINT
  end

  def self.mm2pt(value)
    value*MM2POINT
  end

  def inch2pt(value)
    value*INCH2POINT
  end

  def self.inch2pt(value)
    value*INCH2POINT
  end

  def self.px2pt(value)
    value*PX2POINT
  end

  def convert_to_pt
    if unit == 'mm'
      self.width          = mm2pt(width_in_unit)
      self.height         = mm2pt(height_in_unit)
      self.left_margin    = mm2pt(left_margin_in_unit)
      self.top_margin     = mm2pt(top_margin_in_unit)
      self.right_margin   = mm2pt(right_margin_in_unit)
      self.bottom_margin  = mm2pt(bottom_margin_in_unit)
      self.gutter         = mm2pt(gutter_in_unit)
    elsif unit == 'inch'
      self.width          = inch2pt(width)
      self.height         = inch2pt(height)
      self.left_margin    = inch2pt(left_margin)
      self.top_margin     = inch2pt(top_margin)
      self.right_margin   = inch2pt(right_margin)
      self.bottom_margin  = inch2pt(bottom_margin)
    end
  end

  def front_page_heading_height_in_pt
    front_page_heading_height*body_line_height
  end

  def inner_page_heading_height_in_pt
    inner_page_heading_height*body_line_height
  end

  def layout_rb
    h = {}
    h[:width]       = width
    h[:height]      = height
    h[:left_margin] = left_margin
    h[:top_margin]  = top_margin
    h[:right_margin]= right_margin
    h[:bottom_margin]= bottom_margin
    h[:stroke_width] = 0.5
    columns = eval(page_columns)
    if columns.class == Array
      columns = columns.last
    elsif columns.class == Fixnum
      columns = columns
    end
    column_width = (page_heading_width - (columns - 1)*gutter)/columns
    content=<<~EOF
    RLayout::Container.new(#{h}) do
      x_position = #{left_margin}
      #{columns}.times do
        rectangle(x: x_position, y: #{top_margin}, width: #{column_width}, height: #{page_height}, stroke_width: 0.5)
        x_position += #{column_width} + #{gutter}
      end
      rectangle(x: #{left_margin}, y: #{top_margin}, width: #{page_heading_width}, height: #{front_page_heading_height_in_pt}, fill_color: 'lightGray')
      rectangle(x: #{left_margin}, y: #{top_margin}, width: #{page_heading_width}, height: #{inner_page_heading_height_in_pt}, fill_color: 'darkGray')
    end
    EOF

  end
  # #{raw - 2}.times do |i|
  #   line([#{left_margin}, #{(i + 1)*grid_height}], [#{left_margin + page_heading_width}, #{(i + 1)*grid_height}])
  # end

  def sample_page_path
    path + "/sample"
  end

  def sample_page_layout_path
    sample_page_path + "/layout.rb"
  end

  def pdf_path
    sample_page_path + "/output.pdf"
  end

  def pdf_image_path
    "/#{id}/sample/output.pdf"
  end

  def save_sample_page_layout_rb
    puts "layout_rb:#{layout_rb}"
    system("mkdir -p #{sample_page_path}") unless File.directory?(sample_page_path)
    File.open(sample_page_layout_path, 'w'){|f| f.write layout_rb}
  end

  def generate_sample_pdf
    save_sample_page_layout_rb
    system "cd #{sample_page_path} && /Applications/rjob.app/Contents/MacOS/rjob layout.rb"
  end
end
