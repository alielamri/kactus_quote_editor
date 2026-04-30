require "test_helper"

class QuoteAuditTest < ActiveSupport::TestCase
  test "creates a paper_trail version on quote creation" do
    quote = nil
    assert_difference -> { PaperTrail::Version.where(item_type: "Quote").count }, 1 do
      quote = Quote.create!(name: "New Quote")
    end

    version = quote.versions.last
    assert_equal "create", version.event
  end

  test "creates a paper_trail version on quote update" do
    quote = Quote.create!(name: "Initial Name")

    assert_difference -> { quote.versions.count }, 1 do
      quote.update!(name: "Updated Name")
    end

    version = quote.versions.last
    assert_equal "update", version.event
    assert_equal({ "name" => [ "Initial Name", "Updated Name" ] }, version.object_changes.slice("name"))
  end

  test 'tags the version event as "validate" when status moves to validated' do
    quote = Quote.create!(name: "Quote to validate")

    assert_difference -> { quote.versions.count }, 1 do
      quote.update!(status: :validated)
    end

    version = quote.versions.last
    assert_equal "validate", version.event, "Status change to validated should be tracked as a validate event"
  end

  test 'tags regular update events as "update", not "validate"' do
    quote = Quote.create!(name: "Initial Name")

    quote.update!(name: "Renamed")

    assert_equal "update", quote.versions.last.event
  end

  test "creates a paper_trail version on quote destroy" do
    quote = Quote.create!(name: "Doomed quote")

    assert_difference -> { PaperTrail::Version.where(item_type: "Quote").count }, 1 do
      quote.destroy!
    end

    last_version = PaperTrail::Version.where(item_type: "Quote").order(:created_at).last
    assert_equal "destroy", last_version.event
  end

  test "ignores updated_at changes in versions" do
    quote = Quote.create!(name: "Test")
    initial_count = quote.versions.count

    quote.touch
    assert_equal initial_count, quote.versions.count, "updated_at-only changes must not generate a version"
  end
end
