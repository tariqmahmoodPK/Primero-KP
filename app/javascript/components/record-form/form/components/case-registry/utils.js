/* eslint-disable import/prefer-default-export */
import { object, string } from "yup";

export const buildValidation = (fields, searchByRequiredMessage) => {
  const selectableFields = fields[0].option_strings_text.map(option => [option.id, option.display_text]);

  return object().shape({
    search_by: string().required(searchByRequiredMessage).nullable(),
    ...selectableFields.reduce((prev, current) => {
      return {
        ...prev,
        [current[0]]: string().label(current[1]).when("search_by", { is: current[0], then: string().required() })
      };
    }, {})
  });
};
