INSERT INTO `group_attribute_schema` (`group_attribute_schema_name`, `group_attribute_schema_type`, `group_attribute_schema_is_list`, `group_attribute_schema_is_group_visible`, `group_attribute_schema_is_group_editable`, `group_attribute_schema_is_hardcoded`) VALUES
('codeunite', 'Integer', 0, 1, 0, 0),
('displayname', 'String', 0, 1, 0, 0);

INSERT INTO `user_attribute_schema` (`user_attribute_schema_name`, `user_attribute_schema_type`, `user_attribute_schema_is_list`, `user_attribute_schema_is_user_visible`, `user_attribute_schema_is_user_editable`, `user_attribute_schema_is_hardcoded`) VALUES
('codeunitessup', 'String', 0, 1, 1, 0),
('displayname', 'String', 0, 1, 1, 0),
('dptunite', 'Integer', 0, 1, 1, 0),
('employeetype', 'String', 0, 1, 1, 0),
('givenname', 'String', 0, 1, 1, 0),
('nigend', 'Integer', 0, 1, 1, 0),
('responsabilite', 'String', 0, 1, 1, 0),
('specialite', 'String', 0, 1, 1, 0),
('title', 'String', 0, 1, 1, 0),
('uid', 'String', 0, 1, 1, 0);

-- INSERT INTO `groups` (`group_id`, `display_name`, `creation_date`, `uuid`, `lowercase_display_name`) VALUES
-- (8, 'UNITE Baie-Mahault', '2025-08-30 07:13:54', '88074fe0-6051-3ed6-a3c9-27aba28919f1', 'unite baie-mahault');