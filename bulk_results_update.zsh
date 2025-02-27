#!/bin/zsh
#This script copies vegetation_cover and time_until_next_irrigation props
#from aggregatedProps column of fieldResults to the statistcis column.
#
#It's done in batches: ~ 200 batches based on date for ~34mln or records.
#This was tested and executed on Linux. It's meant to be excuted once, but if the same script executed
#several times, it should not be harmful, as the logic just adds attributes to statistics column, if the data
#is already there, it would be just updated to the same value.
#
#The progress is logged to update_batches.log file, so in there is an error you can start from another start-date
#you better update the TOTAL_DAYS value

#We run the script locally when the tunnel to bastion is open. This should be same as config in
# db_migrations/conf folder
DB_PASSWORD=${IRRIWATCH_STAGING_DATABASE_PASSWORD:-""} # Database password IRRIWATCH_PROD_DATABASE_PASSWORD
DB_USER="postgres"                                   # postgres for remote
DB_HOST="127.0.0.1"                                  # Local cause we use the tunnel
DB_PORT="5432"                                       # This is the port of the tunnel
DB_NAME="irriwatch"                                 
PSQL_CONNECTION_STRING="postgresql://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME"

START_DATE="2021-01-01"
END_DATE="2025-01-01" 
BATCH_COUNT=100           
LOG_FILE="update_batches.log"

TOTAL_DAYS=365 #Days between 2021-03-01 and 2024-12-01
BATCH_SIZE=$(( TOTAL_DAYS / BATCH_COUNT )) #Days in one bacth
# The batch size it's at least one
if [[ $BATCH_SIZE -lt 1 ]]; then
    BATCH_SIZE=1
fi


log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

handle_error() {
    local error_message="$1"
    log_message "ERROR: Batch failed for date range $CURRENT_START_DATE to $CURRENT_END_DATE. Error: $error_message"
    exit 1
}

CURRENT_START_DATE="$START_DATE"
for (( i=1; i<=$BATCH_COUNT; i++ )); do
    # Calculate the end date for the current batch
    CURRENT_END_DATE=$(date -d "$CURRENT_START_DATE + $BATCH_SIZE days" +"%Y-%m-%d")

    # Log the batch start
    log_message "Processing batch $i: $CURRENT_START_DATE to $CURRENT_END_DATE"

    # Run the PostgreSQL update command and capture any errors
	ERROR_OUTPUT=$(psql "$PSQL_CONNECTION_STRING" -c "
    UPDATE \"fieldResults\"
    SET statistics = jsonb_set(
        jsonb_set(
            statistics::jsonb,
            '{vegetationCover}',
            (\"aggregatedProps\"->>'vegetation_cover')::jsonb,
            true
        ),
        '{timeUntilNextIrrigation}',
        (\"aggregatedProps\"->>'time_until_next_irrigation')::jsonb,
        true
    )
    WHERE \"date\" >= '$CURRENT_START_DATE' AND \"date\" <= '$CURRENT_END_DATE' AND  \"aggregatedProps\" ? 'vegetation_cover' AND \"aggregatedProps\" ? 'time_until_next_irrigation';
    " 2>&1)

    # Check if the command failed
    if [[ $? -ne 0 ]]; then
        handle_error "$ERROR_OUTPUT"
    fi

    # Log batch success
    log_message "Batch $i completed successfully."

    # Update the start date for the next batch
    CURRENT_START_DATE=$(date -d "$CURRENT_END_DATE + 1 day" +"%Y-%m-%d")

    # Exit if we've reached or passed the end date
    if [[ "$CURRENT_START_DATE" > "$END_DATE" ]]; then
        break
    fi
done

# Log script completion
log_message "All batches completed successfully."
