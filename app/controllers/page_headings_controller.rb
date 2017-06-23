class PageHeadingsController < ApplicationController
  before_action :set_page_heading, only: [:show, :edit, :update, :destroy]

  # GET /page_headings
  # GET /page_headings.json
  def index
    @page_headings = PageHeading.all
    respond_to do |format|
      format.html
      format.csv { send_data @page_headings.to_csv }
      format.xls # { send_data @products.to_csv(col_sep: "\t") }
    end
  end

  # GET /page_headings/1
  # GET /page_headings/1.json
  def show
  end

  # GET /page_headings/new
  def new
    @page_heading = PageHeading.new
  end

  # GET /page_headings/1/edit
  def edit
  end

  # POST /page_headings
  # POST /page_headings.json
  def create
    @page_heading = PageHeading.new(page_heading_params)

    respond_to do |format|
      if @page_heading.save
        format.html { redirect_to @page_heading, notice: 'Page heading was successfully created.' }
        format.json { render :show, status: :created, location: @page_heading }
      else
        format.html { render :new }
        format.json { render json: @page_heading.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /page_headings/1
  # PATCH/PUT /page_headings/1.json
  def update
    respond_to do |format|
      if @page_heading.update(page_heading_params)
        format.html { redirect_to @page_heading, notice: 'Page heading was successfully updated.' }
        format.json { render :show, status: :ok, location: @page_heading }
      else
        format.html { render :edit }
        format.json { render json: @page_heading.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /page_headings/1
  # DELETE /page_headings/1.json
  def destroy
    @page_heading.destroy
    respond_to do |format|
      format.html { redirect_to page_headings_url, notice: 'Page heading was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_page_heading
      @page_heading = PageHeading.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def page_heading_params
      params.require(:page_heading).permit(:page_number, :section_name, :date, :publication_id)
    end
end