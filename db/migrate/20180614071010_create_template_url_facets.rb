# frozen_string_literal: true

class CreateTemplateUrlFacets < ActiveRecord::Migration[5.1]
  def change
    create_table :template_url_facets do |t|
      t.references :host, foreign_key: true, null: false, index: true, unique: true
      t.string :template_url

      t.timestamps
    end
  end
end
