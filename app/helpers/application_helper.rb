module ApplicationHelper
  def response_matrix_cell_class(response)
    return "response-cell response-cell--empty" if response.nil?

    "response-cell response-cell--#{response.status}"
  end

  def response_matrix_cell_label(response)
    return "—" if response.nil?

    response.status.titleize
  end
end
