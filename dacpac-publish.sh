#!/bin/bash
USAGE="Usage: $0 -f FILE -d DATABASE -S SERVER -U USERNAME -P PASSWORD  ( -d and -f are required; the others have defaults. Only deploys tables by default; use -a to deploy all schema.)"

# These defaults are for convenience in an isolated development environment.
# Don't change them here for production; pass them in.
SERVER="localhost"
USERNAME="sa"
PASSWORD="Your_password123"
_ONLYTABLES="SqlPackageFilter0=IgnoreType(Aggregate);SqlPackageFilter1=IgnoreType(ApplicationRole);SqlPackageFilter2=IgnoreType(Assembly);SqlPackageFilter3=IgnoreType(AssemblySource);SqlPackageFilter4=IgnoreType(AsymmetricKey);SqlPackageFilter5=IgnoreType(AuditAction);SqlPackageFilter6=IgnoreType(AuditActionGroup);SqlPackageFilter7=IgnoreType(AuditActionSpecification);SqlPackageFilter8=IgnoreType(BrokerPriority);SqlPackageFilter9=IgnoreType(BuiltInServerRole);SqlPackageFilter10=IgnoreType(Certificate);SqlPackageFilter11=IgnoreType(CheckConstraint);SqlPackageFilter12=IgnoreType(ClrTableOption);SqlPackageFilter13=IgnoreType(ClrTypeMethod);SqlPackageFilter14=IgnoreType(ClrTypeMethodParameter);SqlPackageFilter15=IgnoreType(ClrTypeProperty);SqlPackageFilter16=IgnoreType(Column);SqlPackageFilter17=IgnoreType(ColumnEncryptionKey);SqlPackageFilter18=IgnoreType(ColumnEncryptionKeyValue);SqlPackageFilter19=IgnoreType(ColumnMasterKey);SqlPackageFilter20=IgnoreType(ColumnStoreIndex);SqlPackageFilter21=IgnoreType(Contract);SqlPackageFilter22=IgnoreType(Credential);SqlPackageFilter23=IgnoreType(CryptographicProvider);SqlPackageFilter24=IgnoreType(DatabaseAuditSpecification);SqlPackageFilter25=IgnoreType(DatabaseCredential);SqlPackageFilter26=IgnoreType(DatabaseDdlTrigger);SqlPackageFilter27=IgnoreType(DatabaseEncryptionKey);SqlPackageFilter28=IgnoreType(DatabaseEventNotification);SqlPackageFilter29=IgnoreType(DatabaseEventSession);SqlPackageFilter30=IgnoreType(DatabaseMirroringLanguageSpecifier);SqlPackageFilter31=IgnoreType(DatabaseOptions);SqlPackageFilter32=IgnoreType(DataCompressionOption);SqlPackageFilter33=IgnoreType(DataType);SqlPackageFilter34=IgnoreType(Default);SqlPackageFilter35=IgnoreType(DefaultConstraint);SqlPackageFilter36=IgnoreType(DmlTrigger);SqlPackageFilter37=IgnoreType(EdgeConstraint);SqlPackageFilter38=IgnoreType(Endpoint);SqlPackageFilter39=IgnoreType(ErrorMessage);SqlPackageFilter40=IgnoreType(EventGroup);SqlPackageFilter41=IgnoreType(EventSession);SqlPackageFilter42=IgnoreType(EventSessionAction);SqlPackageFilter43=IgnoreType(EventSessionDefinitions);SqlPackageFilter44=IgnoreType(EventSessionSetting);SqlPackageFilter45=IgnoreType(EventSessionTarget);SqlPackageFilter46=IgnoreType(EventTypeSpecifier);SqlPackageFilter47=IgnoreType(ExtendedProcedure);SqlPackageFilter48=IgnoreType(ExtendedProperty);SqlPackageFilter49=IgnoreType(ExternalDataSource);SqlPackageFilter50=IgnoreType(ExternalFileFormat);SqlPackageFilter51=IgnoreType(ExternalTable);SqlPackageFilter52=IgnoreType(Filegroup);SqlPackageFilter53=IgnoreType(FileTable);SqlPackageFilter54=IgnoreType(ForeignKeyConstraint);SqlPackageFilter55=IgnoreType(FullTextCatalog);SqlPackageFilter56=IgnoreType(FullTextIndex);SqlPackageFilter57=IgnoreType(FullTextIndexColumnSpecifier);SqlPackageFilter58=IgnoreType(FullTextStopList);SqlPackageFilter59=IgnoreType(HttpProtocolSpecifier);SqlPackageFilter60=IgnoreType(Index);SqlPackageFilter61=IgnoreType(LinkedServer);SqlPackageFilter62=IgnoreType(LinkedServerLogin);SqlPackageFilter63=IgnoreType(Login);SqlPackageFilter64=IgnoreType(MasterKey);SqlPackageFilter65=IgnoreType(MessageType);SqlPackageFilter66=IgnoreType(Parameter);SqlPackageFilter67=IgnoreType(PartitionFunction);SqlPackageFilter68=IgnoreType(PartitionScheme);SqlPackageFilter69=IgnoreType(PartitionSpecification);SqlPackageFilter70=IgnoreType(PartitionValue);SqlPackageFilter71=IgnoreType(Permission);SqlPackageFilter72=IgnoreType(PrimaryKeyConstraint);SqlPackageFilter73=IgnoreType(Procedure);SqlPackageFilter74=IgnoreType(PromotedNodePathForSqlType);SqlPackageFilter75=IgnoreType(PromotedNodePathForXQueryType);SqlPackageFilter76=IgnoreType(Queue);SqlPackageFilter77=IgnoreType(QueueEventNotification);SqlPackageFilter78=IgnoreType(RemoteServiceBinding);SqlPackageFilter79=IgnoreType(ResourceGovernor);SqlPackageFilter80=IgnoreType(ResourcePool);SqlPackageFilter81=IgnoreType(Role);SqlPackageFilter82=IgnoreType(RoleMembership);SqlPackageFilter83=IgnoreType(Route);SqlPackageFilter84=IgnoreType(Rule);SqlPackageFilter85=IgnoreType(ScalarFunction);SqlPackageFilter86=IgnoreType(Schema);SqlPackageFilter87=IgnoreType(SchemaInstance);SqlPackageFilter88=IgnoreType(SearchProperty);SqlPackageFilter89=IgnoreType(SearchPropertyList);SqlPackageFilter90=IgnoreType(SecurityPolicy);SqlPackageFilter91=IgnoreType(SecurityPredicate);SqlPackageFilter92=IgnoreType(SelectiveXmlIndex);SqlPackageFilter93=IgnoreType(Sequence);SqlPackageFilter94=IgnoreType(ServerAudit);SqlPackageFilter95=IgnoreType(ServerAuditSpecification);SqlPackageFilter96=IgnoreType(ServerDdlTrigger);SqlPackageFilter97=IgnoreType(ServerEventNotification);SqlPackageFilter98=IgnoreType(ServerOptions);SqlPackageFilter99=IgnoreType(ServerRoleMembership);SqlPackageFilter100=IgnoreType(Service);SqlPackageFilter101=IgnoreType(ServiceBrokerLanguageSpecifier);SqlPackageFilter102=IgnoreType(Signature);SqlPackageFilter103=IgnoreType(SignatureEncryptionMechanism);SqlPackageFilter104=IgnoreType(SoapLanguageSpecifier);SqlPackageFilter105=IgnoreType(SoapMethodSpecification);SqlPackageFilter106=IgnoreType(SpatialIndex);SqlPackageFilter107=IgnoreType(SqlFile);SqlPackageFilter108=IgnoreType(Statistics);SqlPackageFilter109=IgnoreType(SymmetricKey);SqlPackageFilter110=IgnoreType(SymmetricKeyPassword);SqlPackageFilter111=IgnoreType(Synonym);SqlPackageFilter113=IgnoreType(TableType);SqlPackageFilter114=IgnoreType(TableTypeCheckConstraint);SqlPackageFilter115=IgnoreType(TableTypeColumn);SqlPackageFilter116=IgnoreType(TableTypeDefaultConstraint);SqlPackageFilter117=IgnoreType(TableTypeIndex);SqlPackageFilter118=IgnoreType(TableTypePrimaryKeyConstraint);SqlPackageFilter119=IgnoreType(TableTypeUniqueConstraint);SqlPackageFilter120=IgnoreType(TableValuedFunction);SqlPackageFilter121=IgnoreType(TcpProtocolSpecifier);SqlPackageFilter122=IgnoreType(UniqueConstraint);SqlPackageFilter123=IgnoreType(User);SqlPackageFilter124=IgnoreType(UserDefinedServerRole);SqlPackageFilter125=IgnoreType(UserDefinedType);SqlPackageFilter126=IgnoreType(View);SqlPackageFilter127=IgnoreType(WorkloadGroup);SqlPackageFilter128=IgnoreType(XmlIndex);SqlPackageFilter129=IgnoreType(XmlNamespace);SqlPackageFilter130=IgnoreType(XmlSchemaCollection);"
FILTERS="$_ONLYTABLES"

while [ $# -gt 0 ]; do
	case "$1" in
		-f)
			FILE="$2"
			shift
			;;
		-S)
			SERVER="$2"
			shift
			;;
		-d)
			DATABASE="$2"
			shift
			;;
		-U)
			USERNAME="$2"
			shift
			;;
		-P)
			PASSWORD="$2"
			shift
			;;
		-a) #Deploy All object types, not just tables.
			FILTERS="blah0=blah" #ignored, but can't be blank
			#no arg, no shift
			;;
		--*)
			echo "Illegal option $1"
			echo "$USAGE"
			exit 1
			;;
	esac
	shift $(( $# > 0 ? 1 : 0 ))
done

if [ -z "$DATABASE" ]; then
	echo ERROR: Must specify database name.
	echo "$USAGE"
	exit 1
fi

if [ -z "$FILE" ]; then
	echo ERROR: Must specify DACPAC filename.
	echo "$USAGE"
	exit 1
fi

echo Deploying schema from "$FILE" to "$DATABASE" on "$SERVER" as "$USERNAME"

sqlpackage \
	/Action:Publish /DeployReportPath:"$FILE-deployreport.xml" \
	/SourceFile:"$FILE" /Profile:"/opt/sqlpackage/Database.publish.xml" \
	/TargetConnectionString:"Data Source=tcp:$SERVER;User ID=$USERNAME;Password=$PASSWORD;Initial Catalog=$DATABASE;" \
	/p:DropObjectsNotInSource=False /p:IgnoreAuthorizer=True \
	/p:AdditionalDeploymentContributors=AgileSqlClub.DeploymentFilterContributor \
	/p:AdditionalDeploymentContributorArguments="$FILTERS"

echo "Done."



