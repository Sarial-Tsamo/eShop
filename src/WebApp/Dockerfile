###############
# Build stage
###############

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy central package versions
COPY Directory.Packages.props ./

# Copy WebApp project
COPY src/WebApp/WebApp.csproj ./src/WebApp/

# Restore dependencies
RUN dotnet restore ./src/WebApp/WebApp.csproj

# Copy everything
COPY . .

# Publish WebApp
RUN dotnet publish ./src/WebApp/WebApp.csproj \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false

###############
# Runtime stage
###############

FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app

COPY --from=build /app/publish .

EXPOSE 80

ENV ASPNETCORE_URLS=http://+:80
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["dotnet", "WebApp.dll"]
