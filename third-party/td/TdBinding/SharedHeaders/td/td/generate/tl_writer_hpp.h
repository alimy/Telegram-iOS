//
// Copyright Aliaksei Levin (levlam@telegram.org), Arseny Smirnov (arseny30@gmail.com) 2014-2025
//
// Distributed under the Boost Software License, Version 1.0. (See accompanying
// file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
//
#pragma once

#include "tl_writer_td.h"

#include <cstdint>
#include <string>
#include <vector>

namespace td {

class TD_TL_writer_hpp final : public TD_TL_writer {
 public:
  TD_TL_writer_hpp(const std::string &tl_name, const std::string &string_type, const std::string &bytes_type)
      : TD_TL_writer(tl_name, string_type, bytes_type) {
  }

  bool is_documentation_generated() const final;

  int get_additional_function_type(const std::string &additional_function_name) const final;
  std::vector<std::string> get_additional_functions() const final;

  std::string gen_base_type_class_name(int arity) const final;
  std::string gen_base_tl_class_name() const final;

  std::string gen_output_begin(const std::string &additional_imports) const final;
  std::string gen_output_begin_once() const final;
  std::string gen_output_end() const final;

  std::string gen_forward_class_declaration(const std::string &class_name, bool is_proxy) const final;

  std::string gen_class_begin(const std::string &class_name, const std::string &base_class_name, bool is_proxy,
                              const tl::tl_tree *result) const final;
  std::string gen_class_end() const final;

  std::string gen_class_alias(const std::string &class_name, const std::string &alias_name) const final;

  std::string gen_field_definition(const std::string &class_name, const std::string &type_name,
                                   const std::string &field_name) const final;

  std::string gen_vars(const tl::tl_combinator *t, const tl::tl_tree_type *result_type,
                       std::vector<tl::var_description> &vars) const final;
  std::string gen_function_vars(const tl::tl_combinator *t, std::vector<tl::var_description> &vars) const final;
  std::string gen_uni(const tl::tl_tree_type *result_type, std::vector<tl::var_description> &vars,
                      bool check_negative) const final;
  std::string gen_constructor_id_store(std::int32_t id, int storer_type) const final;

  std::string gen_field_fetch(int field_num, const tl::arg &a, std::vector<tl::var_description> &vars, bool flat,
                              int parser_type) const final;
  std::string gen_field_store(const tl::arg &a, const std::vector<tl::arg> &args,
                              std::vector<tl::var_description> &vars, bool flat, int storer_type) const final;
  std::string gen_type_fetch(const std::string &field_name, const tl::tl_tree_type *tree_type,
                             const std::vector<tl::var_description> &vars, int parser_type) const final;
  std::string gen_type_store(const std::string &field_name, const tl::tl_tree_type *tree_type,
                             const std::vector<tl::var_description> &vars, int storer_type) const final;
  std::string gen_var_type_fetch(const tl::arg &a) const final;

  std::string gen_get_id(const std::string &class_name, std::int32_t id, bool is_proxy) const final;

  std::string gen_function_result_type(const tl::tl_tree *result) const final;

  std::string gen_fetch_function_begin(const std::string &parser_name, const std::string &class_name,
                                       const std::string &parent_class_name, int arity, int field_count,
                                       std::vector<tl::var_description> &vars, int parser_type) const final;
  std::string gen_fetch_function_end(bool has_parent, int field_count, const std::vector<tl::var_description> &vars,
                                     int parser_type) const final;

  std::string gen_fetch_function_result_begin(const std::string &parser_name, const std::string &class_name,
                                              const tl::tl_tree *result) const final;
  std::string gen_fetch_function_result_end() const final;
  std::string gen_fetch_function_result_any_begin(const std::string &parser_name, const std::string &class_name,
                                                  bool is_proxy) const final;
  std::string gen_fetch_function_result_any_end(bool is_proxy) const final;

  std::string gen_store_function_begin(const std::string &storer_name, const std::string &class_name, int arity,
                                       std::vector<tl::var_description> &vars, int storer_type) const final;
  std::string gen_store_function_end(const std::vector<tl::var_description> &vars, int storer_type) const final;

  std::string gen_fetch_switch_begin() const final;
  std::string gen_fetch_switch_case(const tl::tl_combinator *t, int arity) const final;
  std::string gen_fetch_switch_end() const final;

  std::string gen_constructor_begin(int field_count, const std::string &class_name, bool is_default) const final;
  std::string gen_constructor_parameter(int field_num, const std::string &class_name, const tl::arg &a,
                                        bool is_default) const final;
  std::string gen_constructor_field_init(int field_num, const std::string &class_name, const tl::arg &a,
                                         bool is_default) const final;
  std::string gen_constructor_end(const tl::tl_combinator *t, int field_count, bool is_default) const final;

  std::string gen_additional_function(const std::string &function_name, const tl::tl_combinator *t,
                                      bool is_function) const final;
  std::string gen_additional_proxy_function_begin(const std::string &function_name, const tl::tl_type *type,
                                                  const std::string &class_name, int arity,
                                                  bool is_function) const final;
  std::string gen_additional_proxy_function_case(const std::string &function_name, const tl::tl_type *type,
                                                 const std::string &class_name, int arity) const final;
  std::string gen_additional_proxy_function_case(const std::string &function_name, const tl::tl_type *type,
                                                 const tl::tl_combinator *t, int arity, bool is_function) const final;
  std::string gen_additional_proxy_function_end(const std::string &function_name, const tl::tl_type *type,
                                                bool is_function) const final;
};

}  // namespace td
