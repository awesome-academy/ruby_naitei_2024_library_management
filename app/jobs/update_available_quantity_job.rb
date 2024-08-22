class UpdateAvailableQuantityJob < ApplicationJob
  queue_as :default

  def perform book_id, quantity_change
    book_inventory = BookInventory.find_by(book_id:)
    if book_inventory.present?
      book_inventory.increment!(:available_quantity, quantity_change)
    else
      Rails.logger.error "BookInventory not found for book_id: #{book_id}"
    end
  end
end
