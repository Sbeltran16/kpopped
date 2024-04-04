class RenameContentColumnToPostInPosts < ActiveRecord::Migration[7.1]
  def change
    rename_column :posts, :content, :post
    change_column :posts, :post, :text
  end
end
