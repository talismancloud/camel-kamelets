@knative
Feature: AWS S3 Kamelet - Knative broker binding

  Background:
    Given Knative event consumer timeout is 20000 ms
    Given variables
      | aws.s3.scheme | camel |
      | aws.s3.format | plain-text |
      | aws.s3.bucketNameOrArn | mybucket |
      | aws.s3.message | Hello from S3 Kamelet |
      | aws.s3.key | hello.txt |

  Scenario: Create infrastructure
    # Start LocalStack container
    Given Enable service S3
    Given start LocalStack container
    # Create AWS-S3 client
    Given New global Camel context
    Given load to Camel registry amazonS3Client.groovy
    # Create Knative broker
    Given create Knative broker default
    And Knative broker default is running

  Scenario: Verify AWS-S3 Kamelet to Knative binding
    # Create binding
    When load Pipe aws-s3-to-knative-broker.yaml
    And Pipe aws-s3-to-knative-broker is available
    And Camel K integration aws-s3-to-knative-broker is running
    Then Camel K integration aws-s3-to-knative-broker should print Started aws-s3-to-knative-broker
    # Verify Kamelet source
    Given create Knative event consumer service event-consumer-service
    Given create Knative trigger event-service-trigger on service event-consumer-service with filter on attributes
      | type   | org.apache.camel.event |
    Given Camel exchange message header CamelAwsS3Key="${aws.s3.key}"
    Given send Camel exchange to("aws2-s3://${aws.s3.bucketNameOrArn}?amazonS3Client=#amazonS3Client") with body: ${aws.s3.message}
    Then expect Knative event data: ${aws.s3.message}
    And verify Knative event
      | type            | org.apache.camel.event |
      | source          | @ignore@ |
      | id              | @ignore@ |

  Scenario: Remove resources
    # Remove Camel K resources
    Given delete Pipe aws-s3-to-knative-broker
    Given delete Kubernetes service event-consumer-service
    # Remove Knative resources
    Given delete Knative broker default
    # Stop LocalStack container
    Given stop LocalStack container
