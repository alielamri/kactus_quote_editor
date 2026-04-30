require "test_helper"

class ItemAuditTest < ActiveSupport::TestCase
  def setup
    @quote = Quote.create!(name: "Audit Quote")
  end

  test "creates a paper_trail version on item creation" do
    item = nil
    assert_difference -> { PaperTrail::Version.where(item_type: "Item").count }, 1 do
      item = @quote.items.create!(name: "Item 1", quantity: 2, unit_price: 25.0, vat_rate: 20.0)
    end

    version = item.versions.last
    assert_equal "create", version.event
  end

  test "creates a paper_trail version on item update" do
    item = @quote.items.create!(name: "Item", quantity: 1, unit_price: 10.0, vat_rate: 20.0)

    assert_difference -> { item.versions.count }, 1 do
      item.update!(quantity: 5)
    end

    version = item.versions.last
    assert_equal "update", version.event
    assert_equal [ 1, 5 ], version.object_changes["quantity"]
  end

  test "creates a paper_trail version on item destroy" do
    item = @quote.items.create!(name: "Item", quantity: 1, unit_price: 10.0, vat_rate: 20.0)
    item_id = item.id

    assert_difference -> { PaperTrail::Version.where(item_type: "Item", item_id: item_id, event: "destroy").count }, 1 do
      item.destroy!
    end
  end

  test "destroying a quote also creates destroy versions for its items" do
    @quote.items.create!(name: "Item A", quantity: 1, unit_price: 10.0, vat_rate: 20.0)
    @quote.items.create!(name: "Item B", quantity: 1, unit_price: 10.0, vat_rate: 20.0)

    assert_difference -> { PaperTrail::Version.where(item_type: "Item", event: "destroy").count }, 2 do
      @quote.destroy!
    end
  end
end
