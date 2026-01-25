CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_events_user_time ON events(user_id, event_time);
CREATE INDEX idx_events_time ON events(event_time);