require 'spec_helper'

describe QuadiconHelper do
  describe "#render_quadicon" do
    subject { helper.render_quadicon(item, {}) }

    let(:item) do
      FactoryGirl.create(:vm_vmware)#, :type => ManageIQ::Providers::Vmware::InfraManager::Vm.name)
    end

    it "renders quadicon for a vmware vm" do
      expect(subject).to have_selector('div.quadicon')
      expect(subject).to have_selector('div.quadicon div.flobj')
    end
  end

  describe "#render_quadicon_text" do
    subject { helper.render_quadicon_text(item, row) }

    let(:item) do
      FactoryGirl.create(:vm_vmware)
    end

    let(:row) do
      Ruport::Data::Record.new(:id => 10000000000534)
    end

    it "render text for a vmware vm" do
      expect(subject).to have_selector('a')
    end
  end

  describe "truncate text for quad icons" do
    ["front", "middle", "back"].each do |trunc|
      context "remove #{trunc} of text" do
        before(:each) do
          @settings = {:display => {:quad_truncate => trunc[0]}}
        end

        it "when value is nil" do
          text = helper.send(:truncate_for_quad, nil)
          expect(text).to be_empty
        end

        it "when value is < 13 long" do
          text = helper.send(:truncate_for_quad, "Test")
          expect(text).to eq("Test")
        end

        it "when value is 12 long" do
          text = helper.send(:truncate_for_quad, "ABCDEFGHIJKL")
          expect(text).to eq("ABCDEFGHIJKL")
        end

        it "when value is 13 long" do
          text = helper.send(:truncate_for_quad, "ABCDEooo12345")
          expect(text).to eq(case trunc[0]
                             when "f" then "...DEooo12345"
                             when "m" then "ABCDE...12345"
                             when "b" then "ABCDEooo12..."
                             end)
        end

        it "when value is 25 long" do
          text = helper.send(:truncate_for_quad, "ABCDEooooooooooooooo12345")
          expect(text).to eq(case trunc[0]
                             when "f" then "...ooooo12345"
                             when "m" then "ABCDE...12345"
                             when "b" then "ABCDEooooo..."
                             end)
        end
      end
    end
  end

  describe "render_ext_management_system_quadicon" do
    before(:each) do
      @settings = {:quadicons => {:ems => true}}
      @item = FactoryGirl.build(:ems_infra)
      allow(@item).to receive(:hosts).and_return(%w(foo bar))
      allow(@item).to receive(:image_name).and_return("foo")
      @layout = "ems_infra"
    end

    let(:options) { {:size => 72, :typ => 'grid'} }

    it "doesn't display IP Address in the tooltip" do
      rendered = helper.send(:render_ext_management_system_quadicon, @item, options)
      expect(rendered).not_to match(/IP Address/)
    end

    it "displays Host Name in the tooltip" do
      rendered = helper.send(:render_ext_management_system_quadicon, @item, options)
      expect(rendered).to match(/Hostname/)
    end
  end

  describe "render_service_quadicon" do
    let(:service) { FactoryGirl.build(:service, :id => 100) }
    let(:options) { {:size => 72, :typ => 'grid'} }
    it "display service quadicon" do
      allow(helper).to receive(:url_for).and_return("/path")

      rendered = helper.send(:render_service_quadicon, service, options, 'service.png')
      expect(rendered).to have_selector('div.flobj', :count => 2)
    end
  end
end
