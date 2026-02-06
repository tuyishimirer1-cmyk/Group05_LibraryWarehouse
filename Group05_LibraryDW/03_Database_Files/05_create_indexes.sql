-- INDEXES FOR PERFORMANCE
USE library_analytics_dw;

-- Fact table indexes
CREATE INDEX idx_fact_date ON fact_library_usage(date_key);
CREATE INDEX idx_fact_student ON fact_library_usage(student_key);
CREATE INDEX idx_fact_resource ON fact_library_usage(resource_key);
CREATE INDEX idx_fact_source ON fact_library_usage(source_system);

-- Dimension table indexes
CREATE INDEX idx_student_id ON dim_student(student_id);
CREATE INDEX idx_resource_id ON dim_resource(resource_id);
CREATE INDEX idx_date_full ON dim_date(full_date);