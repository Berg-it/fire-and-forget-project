resource "aws_api_gateway_rest_api" "fire_and_forget" {
  name = "fire_and_forget"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "generate_report_resource" {
  rest_api_id = aws_api_gateway_rest_api.fire_and_forget.id
  parent_id   = aws_api_gateway_rest_api.fire_and_forget.root_resource_id
  path_part   = "generate-report"
}

###Put item for generate report
resource "aws_api_gateway_method" "put_dynamodb_method" {
  rest_api_id      = aws_api_gateway_rest_api.fire_and_forget.id
  resource_id      = aws_api_gateway_resource.generate_report_resource.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "put_dynamodb_integration" {
  rest_api_id = aws_api_gateway_rest_api.fire_and_forget.id
  resource_id = aws_api_gateway_method.put_dynamodb_method.resource_id
  http_method = aws_api_gateway_method.put_dynamodb_method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.aws_region}:dynamodb:action/PutItem"
  credentials             = "${aws_iam_role.api_gateway_role.arn}" 

  request_templates = {
      "application/json" = <<EOF
        {
          "TableName": "${aws_dynamodb_table.dynamodb_table.name}",
          "Item": {
            "Id": {
                  "S": "$input.path('$.id')"
              }
          }          
        }
      EOF
    }
}

resource "aws_api_gateway_method_response" "put_item_response_200" {
  rest_api_id = aws_api_gateway_rest_api.fire_and_forget.id
  resource_id = aws_api_gateway_resource.generate_report_resource.id
  http_method = aws_api_gateway_method.put_dynamodb_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "put_item_response" {
  depends_on  = [aws_api_gateway_integration.put_dynamodb_integration]
  rest_api_id = aws_api_gateway_rest_api.fire_and_forget.id
  resource_id = aws_api_gateway_resource.generate_report_resource.id
  http_method = aws_api_gateway_method.put_dynamodb_method.http_method
  status_code = aws_api_gateway_method_response.put_item_response_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

###Get item for generate report

resource "aws_api_gateway_resource" "generate_report_resource_get" {
    rest_api_id = aws_api_gateway_rest_api.fire_and_forget.id
    parent_id   = aws_api_gateway_resource.generate_report_resource.id
    path_part   = "{id}"
  }

resource "aws_api_gateway_method" "get_dynamodb_method" {
  rest_api_id      = aws_api_gateway_rest_api.fire_and_forget.id
  resource_id      = aws_api_gateway_resource.generate_report_resource_get.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
  request_parameters = {
    "method.request.path.id" = true
  }
}

resource "aws_api_gateway_integration" "get_dynamodb_integration" {
  rest_api_id = aws_api_gateway_rest_api.fire_and_forget.id
  resource_id = aws_api_gateway_method.get_dynamodb_method.resource_id
  http_method = aws_api_gateway_method.get_dynamodb_method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.aws_region}:dynamodb:action/GetItem"
  credentials             = "${aws_iam_role.api_gateway_role.arn}" 

  request_templates = {//TODO
      "application/json" = <<EOF
        {
          "TableName": "${aws_dynamodb_table.dynamodb_table.name}",
          "Key": {
              "Id": {
                "S": "$input.params('id')"
              }
            }       
        }
      EOF
    }
}

resource "aws_api_gateway_method_response" "get_item_response_200" {
  rest_api_id = aws_api_gateway_rest_api.fire_and_forget.id
  resource_id = aws_api_gateway_resource.generate_report_resource_get.id
  http_method = aws_api_gateway_method.get_dynamodb_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "get_item_response" {
    depends_on  = [aws_api_gateway_integration.get_dynamodb_integration]
    rest_api_id = aws_api_gateway_rest_api.fire_and_forget.id
    resource_id = aws_api_gateway_resource.generate_report_resource_get.id
    http_method = aws_api_gateway_method.get_dynamodb_method.http_method
    status_code = aws_api_gateway_method_response.get_item_response_200.status_code
    response_parameters = {
      "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }
    
    response_templates = {
        "application/json" = <<EOF
          {
            "id": $input.path('$.Item.Id.S'),
            "report_status": $input.path('$.Item.report_status.S')
          }
    EOF
      }    

}


#Since the API Gateway usage plans feature was launched on August 11, 
#2016, usage plans are now required to associate an API key with an API stage
/*resource "aws_api_gateway_usage_plan" "myusageplan" {
  name = "my_usage_plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.fire_and_forget.id
    stage  = aws_api_gateway_deployment.deployment_stage.stage_name
  }
}
resource "aws_api_gateway_api_key" "mykey" {
  name = "my_key"
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.mykey.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.myusageplan.id
}

resource "aws_api_gateway_deployment" "deployment_stage" {
  rest_api_id = aws_api_gateway_rest_api.fire_and_forget.id
  stage_name  = "dev"
}*/