export DATAMODEL_WRAPPER="$PROJECT_DATAMODEL_PATH/$DATA_MODELD_NAME"

export DATAMODEL_CURRENT=`/usr/libexec/PlistBuddy -c "print _XCCurrentVersionName" "$DATAMODEL_WRAPPER"/.xccurrentversion`

export DATAMODEL_PATH="$DATAMODEL_WRAPPER/$DATAMODEL_CURRENT"

export DATAMODEL_HEADER_PATH="$PROJECT_DATAMODEL_PATH/goTogetherDataModelHeaders.h"

# printenv > ~/Desktop/testings.txt

if type -P mogenerator &>/dev/null; then

if [ -z "${MODEL_BASE_CLASS+xxx}" ]; then

mogenerator --model "$DATAMODEL_PATH" -M "$MACHINE_FOLDER_GROUP_PATH" -H "$HUMAN_FOLDER_GROUP_PATH" --includeh "$DATAMODEL_HEADER_PATH" --template-var arc=$IS_ARC

else

mogenerator --model "$DATAMODEL_PATH" --base-class "$MODEL_BASE_CLASS" -M "$MACHINE_FOLDER_GROUP_PATH" -H "$HUMAN_FOLDER_GROUP_PATH" --includeh "$DATAMODEL_HEADER_PATH" --template-var arc=$IS_ARC

fi

fi