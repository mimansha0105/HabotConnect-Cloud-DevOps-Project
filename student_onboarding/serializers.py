from rest_framework import serializers


def validate_yes_no(value):
    allowed_values = ["Yes", "No"]

    if value not in allowed_values:
        raise serializers.ValidationError(
            "This field must be either Yes or No."
        )

    return value


class StudentOnboardingSerializer(serializers.Serializer):
    student_name = serializers.CharField(max_length=100)
    age = serializers.IntegerField(min_value=5, max_value=18)
    parent_email = serializers.EmailField()
    requires_learning_support = serializers.CharField(
        validators=[validate_yes_no]
    )
    

